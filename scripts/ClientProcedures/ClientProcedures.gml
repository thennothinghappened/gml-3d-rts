
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
	 * The server will periodically send clients a heartbeat message at an agreed upon interval.
	 * 
	 * @see {HEARTBEAT_MESSAGE_INTERVAL_MILLISECONDS}
	 * @see {HEARTBEAT_MESSAGE_MAX_MISS_COUNT}
	 */
	static heartbeat = new JsonRpcProcedure("heartbeat", ClientHeartbeatRequest, ClientHeartbeatResponse);
	
	/**
	 * The full list of procedures, to register against.
	 */
	static procedureList = [
		heartbeat
	];
	
}

new ClientProcedures();
