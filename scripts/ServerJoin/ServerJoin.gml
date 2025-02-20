
/**
 * Information sent from a client to a server upon connecting.
 * 
 * @param {String} uuid Unique ID for the joining player.
 * @param {String} desiredUsername The desired username the client wishes to use.
 */
function ServerJoinRequest(
	uuid,
	desiredUsername
) : Message() constructor {
	
	self.uuid = uuid;
	self.desiredUsername = desiredUsername;
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return { uuid, desiredUsername };
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
		Assert.cond(is_string(json[$ "uuid"]));
		Assert.cond(is_string(json[$ "desiredUsername"]));
		
		return new ServerJoinRequest(json.uuid, json.desiredUsername);
		
	};
	
}

new ServerJoinRequest("", "");

/**
 * Information sent from the server to a newly connecting client.
 * 
 * @param {String} username The actual username the server has assigned to you.
 * @param {Array<Struct.PlayerDetails>} playerList of players in the server.
 */
function ServerJoinResponse(
	username,
	playerList
) : Message() constructor {
	
	self.username = username;
	self.playerList = playerList;
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return { username, playerList };
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
		
		var username = json[$ "username"];
		Assert.cond(is_string(username));
		
		var playerListJson = json[$ "playerList"];
		Assert.cond(is_array(playerListJson));
		
		var playerList = array_map(playerListJson, PlayerDetails.fromJson);
		return new ServerJoinResponse(username, playerList);
		
	};
	
}

new ServerJoinResponse("", []);

/**
 * Details about a given client on the server.
 * 
 * @param {String} uuid
 * @param {String} username
 */
function PlayerDetails(uuid, username) : Message() constructor {
	
	self.uuid = uuid;
	self.username = username;
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		return { uuid, username };
	};
	
	/**
	 * Deserialise this message from JSON.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json The serialised JSON data to parse.
	 * @returns {Struct.PlayerDetails}
	 */
	static fromJson = function(json) {
		
		Assert.cond(is_struct(json));
		
		var uuid = json[$ "uuid"];
		Assert.cond(is_string(uuid));
		
		var username = json[$ "username"];
		Assert.cond(is_string(username));
		
		return new PlayerDetails(uuid, username);
		
	};
	
}

new PlayerDetails("", "");
