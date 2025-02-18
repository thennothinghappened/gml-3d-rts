
/**
 * Information sent from a client to a server upon connecting.
 * 
 * @param {String} desiredUsername The desired username the client wishes to use.
 */
function ServerJoinRequest(
	desiredUsername
) : Message() constructor {
	
	self.desiredUsername = desiredUsername;
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return { desiredUsername };
	};
	
	/**
	 * Deserialise this message from JSON.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json The serialised JSON data to parse.
	 * @returns {Struct.ServerJoinRequest}
	 */
	static fromJson = function(json) {
		
		Assert.cond(is_struct(json));
		Assert.cond(is_string(json[$ "desiredUsername"]));
		
		return new ServerJoinRequest(json.desiredUsername);
		
	};
	
}

new ServerJoinRequest("");

/**
 * Information sent from the server to a newly connecting client.
 * 
 * @param {Id.Socket} yourId Unique identifier assigned by the server for this client.
 * @param {Array<Id.Socket>} clientList List of client IDs in the server.
 */
function ServerJoinResponse(
	yourId,
	clientList
) : Message() constructor {
	
	self.yourId = yourId;
	self.clientList = clientList;
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return { yourId, clientList };
	};
	
	/**
	 * Deserialise this message from JSON.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json The serialised JSON data to parse.
	 * @returns {Struct.ServerJoinResponse}
	 */
	static fromJson = function(json) {
		
		Assert.cond(is_struct(json));
		Assert.cond(is_real(json[$ "yourId"]));
		Assert.cond(is_array(json[$ "clientList"]));
		Assert.cond(array_all(json[$ "clientList"], is_real));
		
		return new ServerJoinResponse(json.yourId, json.clientList);
		
	};
	
}

new ServerJoinResponse(0, []);
