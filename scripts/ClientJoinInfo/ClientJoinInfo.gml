
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
	 * Convert this message to a serialisable string of JSON.
	 * @returns {String}
	 */
	static toJson = function() {
		return json_stringify(self);
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
