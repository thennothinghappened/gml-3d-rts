
/**
 * Information sent from the server to a newly connecting client.
 * 
 * @param {Real} yourId Unique identifier assigned by the server for this client.
 * @param {Array<Real>} clientList List of client IDs in the server.
 */
function ServerJoinInfo(
	yourId,
	clientList
) : Message() constructor {
	
	self.yourId = yourId;
	self.clientList = clientList;
	
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
	 * @returns {Struct.ServerJoinInfo}
	 */
	static fromJson = function(json) {
		
		Assert.cond(is_struct(json));
		Assert.cond(is_real(json[$ "yourId"]));
		Assert.cond(is_array(json[$ "clientList"]));
		Assert.cond(array_all(json[$ "clientList"], is_real));
		
		return new ServerJoinInfo(json.yourId, json.clientList);
		
	};
	
}

new ServerJoinInfo(0, []);
