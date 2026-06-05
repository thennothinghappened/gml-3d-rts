
/**
 * The list of procedures on a game server.
 */
#macro ServerProc __serverProcedures()

function __serverProcedures() {
	static procedures = {
		/**
		 * Clients call this to inform the server of their configuration. In response,
		 * the server informs them of the client list, and their unique ID in the server.
		 */
		join: new JsonRpcProcedure("join", C2S_ConnectBeginHandshake, S2C_ConnectSuccess),
		
		/**
		 * A client sends a message to other players.
		 */
		sendChatMessage: new JsonRpcProcedure("sendChatMessage", C2S_ChatMessage, undefined),
	};
	
	return procedures;
}
