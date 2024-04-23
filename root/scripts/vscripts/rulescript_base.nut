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
	constructor( k, b, t )
	{
		key = k
		bottom = b
		top = t
	}

	//member function
	function Describe()
	{
		printl( "Criterion " + key + " " + bottom + ".." + top )
	}

	//property
	key = null;
	bottom = null;
	top = null;
}

// Define a functor criterion, where the comparator is a function returning a bool
class CriterionFunc {
	//constructor
	constructor( k, f )
	{
		key = k
		func = f
	}

	//member function
	function Describe()
	{
		printl( "Criterion functor " + key + " -> " + func )
	}

	//property
	key = null;
	func = null;
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

	function SelectResponse()
	{
		local debug = Convars.GetFloat("rr_debugresponses")
		if ( debug > 0 ) {
			print("Matched rule: " )
			Describe( false )
		}
		assert(responses.len() != 0)

		local res_index
		if ( group_params.permitrepeats ) {
			// just randomly pick a response
			res_index = RandomInt( 0, responses.len() - 1 )
		}
		else {
			local unplayed_count = unplayed_responses.len();
			switch(unplayed_count) {
				case 0: // out of unplayed responses, reset
					ResetUnplayedResponsesStack();
					unplayed_count = unplayed_responses.len();
					break;
				case 1: //this will be last response so disable to not match it again in this round
					if(group_params.norepeat) {
						Disable();
					}
			}
			// okay, now pick a response

			if ( group_params.sequential ) {
				res_index = unplayed_responses.pop()
			}
			else {
				// choose randomly from available unplayed responses
				res_index = unplayed_responses.remove(RandomInt( 0, unplayed_count - 1 ))
			}
		}

		local R = responses[res_index]
		if ( "speakonce" in R.params ) {
			responses.remove(res_index)
			foreach(ix, rix in unplayed_responses) {
				if(rix > res_index) {
					unplayed_responses[ix] = rix - 1;
				}
			}
		}
		local chosen = {}
		//chosen response that will be returned, set to empty unless it passes the odds
		//ensures single return in this function and no duplicate check
		//should we try to pick other response if odds don't pass instead if available ?
		//TODO check regular talker odds behavior
		if ( !("odds" in R.params) || RandomInt(0, 100) <= R.params.odds ) {
			if ( debug > 0 ) {
				print("Matched " )
				R.Describe()
			}
			if ( "fire" in R.params ) {
				//just fire whatever, no good reason to limit this to single logic_relay
				EntFire( R.params.fire[0], R.params.fire[1], "", R.params.fire[2])
			}
			chosen = R
		}

		if ( group_params.matchonce || responses.len() == 0) {
			Disable()
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

	// stack of unplayed_responses
	unplayed_responses = null;
}
