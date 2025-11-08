
/**
 * Information sent from a client to a server upon connecting.
 * 
 * @param {String} username The desired username the client wishes to use.
 */
function ServerJoinRequest(username) : Message() constructor
{
	self.username = username;
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function()
	{
		return { username };
	}
	
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
	static fromJson = function(json)
	{
		Assert.cond(is_struct(json));
		Assert.cond(is_string(json[$ "username"]));
		
		return new ServerJoinRequest(json.username);
	}
}

new ServerJoinRequest("");
