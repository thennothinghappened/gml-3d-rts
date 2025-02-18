
/**
 * Shorthand macro for accessing the list of client procedures.
 * 
 * This basically just exists because the GameMaker IDE's Code Editor 2 refuses to autocomplete constructor names
 * if the previously typed keyword was not `new`.
 */
#macro ClientProc ClientProcedures

/**
 * The list of procedures on a game client.
 */
function ClientProcedures() constructor {
	
	/**
	 * The full list of procedures, to register against.
	 */
	static procedureList = [
		
	];
	
}

new ClientProcedures();
