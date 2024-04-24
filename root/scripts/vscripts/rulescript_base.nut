// Testbed for decision-engine (response rules) hookup.

function rrDebugPrint( string )
{
	printl( "RR_TESTBED: " + string )
}

function rrPrintTable( tabl, prefix = "\t" )
{
	foreach ( k,v in tabl )
		print(prefix + k + " : " + v + "\n")
}


// Define an individual "static" criterion, varying between a bottom and top integral value
class Criterion {
	//constructor
	constructor( k, b, t, w=1 )
	{
		key = k
		bottom = b
		top = t
		if(w > 0) {
			weight = w
		}
	}

	//member function
	function Describe()
	{
		printl( "Criterion " + key + " " + bottom + ".." + top + " weight " + weight )
	}

	function _typeof() {
		return "Criterion";
	}

	//property
	key = null;
	bottom = null;
	top = null;
	weight = 1;
}

class OptionalCriterion extends Criterion {
	optional = 1
	function Describe() {
		print( "Optional " );
		base.Describe();
	}

	function _typeof() {
		return "OptionalCriterion";
	}
}
// Define a functor criterion, where the comparator is a function returning a bool
class CriterionFunc {
	//constructor
	constructor( k, f, w=1)
	{
		key = k
		func = f
		if(w > 0) {
			weight = w
		}
	}

	//member function
	function Describe()
	{
		printl( "Criterion functor " + key + " -> " + func )
	}

	function _typeof() {
		return "CriterionFunc";
	}

	//property
	key = null;
	func = null;
	weight = 1;


}

class OptionalCriterionFunc extends CriterionFunc {
	optional = 1
	function Describe() {
		print( "Optional " );
		base.Describe();
	}

	function _typeof() {
		return "OptionalCriterionFunc";
	}
}
// Multiple lines
// response <responsegroupname>
// {
//		[permitrepeats]   ; optional parameter, by default we visit all responses in group before repeating any
//		[sequential]	  ; optional parameter, by default we randomly choose responses, but with this we walk through the list starting at the first and going to the last
//		[norepeat]		  ; Once we've run through all of the entries, disable the response group
//		responsetype1 parameters1 [nodelay | defaultdelay | delay interval ] [speakonce] [odds nnn] [respeakdelay interval] [soundelvel "SNDLVL_xxx"] [displayfirst] [ displaylast ] weight nnn
//		responsetype2 parameters2 [nodelay | defaultdelay | delay interval ] [speakonce] [odds nnn] [respeakdelay interval] [soundelvel "SNDLVL_xxx"] [displayfirst] [ displaylast ] weight nnn
//		etc.
// }


// Represents an individual rule as sent from script to C++
// TODO: handle ApplyContextToWorld
class RRule {
	constructor( name, crits, _responses, _group_params )
	{
		// type-check
		assert( _responses.len() > 0 )

		rulename = name
		criteria = crits
		original_responses = _responses
		responses = clone _responses
		group_params = _group_params
	}

	function Init() {
		if(original_responses.len() != responses.len()) {
			//speakonce param can remove a response from responses
			responses = clone original_responses
		}
		ResetSelectionState();
		enabled = true;
	}

	function ResetSelectionState() {
		selection_state = clone _selection_state;
		ProcessDisplayFirstLast();

		selection_state.unplayed_responses = []
		for(local ix = responses.len() - 1; ix >= 0; ix--) {
			selection_state.unplayed_responses.append(ix);
		}
	}

	function ProcessDisplayFirstLast() {
		for(local ix = responses.len() - 1; ix >= 0; ix--) {
			if("displayfirst" in responses[ix].params) {
				if(selection_state.displayfirst != null) {
					printl("warning multiple displayfirst params used in " + rulename);
					continue;
				}
				selection_state.displayfirst = responses.remove(ix);
			}
			else if("displaylast" in responses[ix].params) {
				if(selection_state.displaylast != null) {
					printl("warning multiple displaylast params used in " + rulename);
					continue;
				}
				selection_state.displaylast = responses.remove(ix);
			}
		}
	}

	function Describe( verbose = true )
	{
		printl( rulename + "\n" + criteria.len() + " crits, " + responses.len() + " responses" )
		if ( verbose )
		{
			foreach (crit in criteria)
			{
				crit.Describe()
			}
			foreach (resp in responses)
			{
				resp.Describe()
			}
			printl("selection_state:")
			foreach ( k,v in selection_state )
				print("\t" + k + " : " + v + "\n")
			print("\n")
		}
	}

	// When a rule matches, call this to pick a response.
	// TODO: test

	function SelectResponse() {
		local debug = Convars.GetFloat("rr_debugresponses")
		if ( debug != 0 ) {
			print("Matched rule: " )
			Describe( false )
		}

		local R = selection_state.displayfirst;
		if(R) {
			selection_state.displayfirst = null;
			if( !("speakonce" in R.params) ) {
				//was chosen to display first so put back among other responses
				responses.append(R);
			}
		}
		else {
			local res_index
			if(group_params.permitrepeats) {
				res_index = RandomInt( 0, responses.len() - 1 )
			}
			else if(group_params.sequential) {
				res_index = selection_state.unplayed_responses.pop()
			}
			else {
				// choose randomly from available unplayed responses
				local i = RandomInt( 0, selection_state.unplayed_responses.len() - 1)
				res_index = selection_state.unplayed_responses.remove(i)
			}
			R = responses[res_index]
			if ( "speakonce" in R.params ) {
				responses.remove(res_index)
				foreach(ix, rix in selection_state.unplayed_responses) {
					if(rix > res_index) {
						selection_state.unplayed_responses[ix] = rix - 1;
					}
				}
			}
		}
		//chosen response that will be returned, set to empty unless it passes the odds
		//TODO check regular talker odds behavior
		local chosen = {}

		if ( !("odds" in R.params) || RandomInt(0, 100) <= R.params.odds ) {
			if ( debug != 0 ) {
				print("Matched ")
				R.Describe()
			}
			if ( "fire" in R.params ) {
				EntFire( R.params.fire[0], R.params.fire[1], "", R.params.fire[2])
			}
			chosen = R
		}
		if ( group_params.matchonce ) {
			Disable()
			return chosen;
		}

		//if we permit repeats we don't care about unplayed_responses
		if( !group_params.permitrepeats && selection_state.unplayed_responses.len() == 0 ) {
			if(selection_state.displaylast) {
				responses.append(selection_state.displaylast);
				selection_state.unplayed_responses.append(responses.len() - 1)
				selection_state.displaylast = null;
			}
			else if(group_params.norepeat) {
				Disable();
			}
			else {
				ResetSelectionState();
			}
		}

		//speakonces or displayfirst/displaylast in 2 response long responses can cause this
		if(responses.len() == 0) {
			if(selection_state.displaylast) {
				responses.append(selection_state.displaylast);
				selection_state.displaylast = null;
			}
			else {
				Disable();
			}
		}

		return chosen
	}

	// tell the response engine to disable me
	function Disable()
	{
		enabled = false;
		if(Convars.GetFloat("rr_debugresponses") != 0) {
			printl( "Matching of rule " + rulename + " disabled until next round" )
		}
		//printl( "TODO: rule " + rulename + " wants to disable itself." )
	}

	function _typeof() {
		return "RRule";
	}

	// properties
	rulename = null;
	criteria = null;
	responses = null;
	original_responses = null;
	group_params = null;

	enabled = true;

	// stack of unplayed_responses with firts response on top
	selection_state = null
	static _selection_state = {
		unplayed_responses = null
		displayfirst = null
		displaylast = null
	}

}
