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

		Init();
	}

	function Init() {
		if(original_responses.len() != responses.len()) {
			//speakonce param can remove a response from responses
			responses = clone original_responses
		}
		ResetUnplayedResponsesStack();
		enabled = true;
	}

	function ResetUnplayedResponsesStack() {
		unplayed_responses = []
		for(local ix = responses.len() - 1; ix >= 0; ix--) {
			unplayed_responses.append(ix);
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
		if ( debug > 0 ) {
			print("Matched rule: " )
			Describe( false )
		}
		assert(responses.len() != 0)

		local res_index
		if(group_params.permitrepeats) {
			res_index = RandomInt( 0, responses.len() - 1 )
		}
		else if(group_params.sequential) {
			res_index = unplayed_responses.pop()
		}
		else {
			// choose randomly from available unplayed responses
			res_index = unplayed_responses.remove(RandomInt( 0, unplayed_responses.len() - 1 ))
		}
		//chosen response that will be returned, set to empty unless it passes the odds
		//TODO check regular talker odds behavior
		local R = responses[res_index], chosen = {}
		if ( "speakonce" in R.params ) {
			responses.remove(res_index)
			foreach(ix, rix in unplayed_responses) {
				if(rix > res_index) {
					unplayed_responses[ix] = rix - 1;
				}
			}
		}
		if ( !("odds" in R.params) || RandomInt(0, 100) <= R.params.odds ) {
			if ( debug > 0 ) {
				print("Matched ")
				R.Describe()
			}
			if ( "fire" in R.params ) {
				EntFire( R.params.fire[0], R.params.fire[1], "", R.params.fire[2])
			}
			chosen = R
		}
		if ( group_params.matchonce || responses.len() == 0) {
			Disable()
		}
		else if( unplayed_responses.len() == 0 ) {
			if(group_params.norepeat) {
				Disable();
			}
			else {
				ResetUnplayedResponsesStack();
			}
		}
		return chosen
	}

	// tell the response engine to disable me
	function Disable()
	{
		enabled = false;
		if(Convars.GetFloat("rr_debugresponses") > 0) {
			printl( "Matching of rule " + rulename + " disabled until next round" )
		}
		//printl( "TODO: rule " + rulename + " wants to disable itself." )
	}

	// properties
	rulename = null;
	criteria = null;
	responses = null;
	original_responses = null;
	group_params = null;

	enabled = true;

	// stack of unplayed_responses with firts response on top
	unplayed_responses = null;
}
