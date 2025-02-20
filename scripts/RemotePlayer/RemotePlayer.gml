
/**
 * A player connected to the local server.
 * 
 * @param {Id.Socket} socketId The identifier on the network for this client.
 * @param {String} uuid A unique identifier for this player provided to the server.
 * @param {String} username The unique username of this client.
 */
function RemotePlayer(socketId, uuid, username) constructor {
	
	self.socketId = socketId;
	self.uuid = uuid;
	self.username = username;
	
	/**
	 * The number of heartbeat messages that have not yet been acknowledged.
	 * @see {HEARTBEAT_MESSAGE_MAX_MISS_COUNT}
	 */
	self.unacknowledgedHeartbeats = 0;
	
}
