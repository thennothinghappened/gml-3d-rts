
/**
 * Information sent from a client to a server upon connecting.
 * 
 * @param {String} desiredUsername The desired username the client wishes to use.
 */
function ClientJoinInfo(
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
	 * @returns {Struct.ClientJoinInfo}
	 */
	static fromJson = function(json) {
		
		Assert.cond(is_struct(json));
		Assert.cond(is_string(json[$ "desiredUsername"]));
		
		return new ClientJoinInfo(json.desiredUsername);
		
	};
	
}

new ClientJoinInfo("");
