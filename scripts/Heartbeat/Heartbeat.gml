
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
function S2C_Heartbeat() : Message() constructor {
	static toJson = function() {
		return "ping";
	}
	
	static fromJson = function(json) {
		Assert.eq(json, "ping");
		return new S2C_Heartbeat();
	}
}

new S2C_Heartbeat();

/**
 * A heartbeat pong from the client to the server with no data.
 */
function C2S_HeartbeatReply() : Message() constructor {
	static toJson = function() {
		return "pong";
	}
	
	static fromJson = function(json) {
		Assert.eq(json, "pong");
		return new C2S_HeartbeatReply();
	}
}

new C2S_HeartbeatReply();
