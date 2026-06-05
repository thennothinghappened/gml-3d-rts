
/**
 * The list of procedures on a game client.
 */
#macro ClientProc __clientProcedures()

function __clientProcedures() {
	static procedures = {
		/**
		 * The server will periodically send clients a heartbeat message at an agreed upon interval.
		 * 
		 * @see {HEARTBEAT_MESSAGE_INTERVAL_MILLISECONDS}
		 * @see {HEARTBEAT_MESSAGE_MAX_MISS_COUNT}
		 */
		heartbeat: new JsonRpcProcedure("heartbeat", S2C_Heartbeat, C2S_HeartbeatReply),
		
		/**
		 * Another player has joined the server.
		 */
		otherPlayerJoined: new JsonRpcProcedure("otherPlayerJoined", S2C_OtherPlayerJoined, undefined),
		
		/**
		 * A player has written a message to the chat.
		 */
		addChatMessage: new JsonRpcProcedure("addChatMessage", S2C_ChatMessageAdded, undefined),
	};
	
	return procedures;
}
