
/**
 * Shorthand macro for accessing the list of server procedures.
 * 
 * This basically just exists because the GameMaker IDE's Code Editor 2 refuses to autocomplete constructor names
 * if the previously typed keyword was not `new`.
 */
#macro ServerProc ServerProcedures

/**
 * The list of procedures on a game server.
 */
function ServerProcedures() constructor {
	
	/**
	 * Clients call this to inform the server of their configuration. In response,
	 * the server informs them of the client list, and their unique ID in the server.
	 */
	static join = new JsonRpcProcedure("join", ServerJoinRequest, ServerJoinResponse);
	
	/**
	 * The full list of procedures, to register against.
	 */
	static procedureList = [
		join
	];
	
}

new ServerProcedures();
