
/**
 * The interval at which heartbeat messages are sent to the client by the server.
 */
#macro HEARTBEAT_MESSAGE_INTERVAL_MILLISECONDS 1000

/**
 * The maximum number of missed heartbeats before:
 * 
 * **On the server:** The server will consider the client to have lost connection.
 * 
 * **On the client:** The client will consider the server to have lost connection.
 */
#macro HEARTBEAT_MESSAGE_MAX_MISS_COUNT 10

/**
 * A heartbeat ping from the server to the client with no data.
 */
function ClientHeartbeatRequest() : Message() constructor {
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return "ping";
	};
	
	/**
	 * Deserialise this message from JSON.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json The serialised JSON data to parse.
	 * @returns {Struct.ClientHeartbeatRequest}
	 */
	static fromJson = function(json) {
		Assert.eq(json, "ping");
		return new ClientHeartbeatRequest();
	};
	
}

new ClientHeartbeatRequest();

/**
 * A heartbeat pong from the client to the server with no data.
 */
function ClientHeartbeatResponse() : Message() constructor {
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return "pong";
	};
	
	/**
	 * Deserialise this message from JSON.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json The serialised JSON data to parse.
	 * @returns {Struct.ClientHeartbeatResponse}
	 */
	static fromJson = function(json) {
		Assert.eq(json, "pong");
		return new ClientHeartbeatResponse();
	};
	
}

new ClientHeartbeatResponse();
