
/**
 * Another player has joined the server.
 * 
 * @param {Id.Socket} _id
 * @param {String} _username
 */
function S2C_OtherPlayerJoined(_id, _username) : Message() constructor {
	id = _id;
	username = _username;
	
	static toJson = function() {
		return self;
	}
	
	static fromJson = function(json) {
		Assert.cond(is_struct(json));
		Assert.cond(is_real(json.id));
		Assert.cond(is_string(json.username));
		
		return new S2C_OtherPlayerJoined(json.id, json.username);
	}
}

new S2C_OtherPlayerJoined(0, "");
