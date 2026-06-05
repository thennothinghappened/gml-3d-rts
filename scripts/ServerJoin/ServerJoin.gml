
/**
 * Information sent from a client to a server upon connecting.
 * 
 * @param {String} _desiredUsername The desired username the client wishes to use.
 */
function C2S_ConnectBeginHandshake(_desiredUsername) : Message() constructor {
	desiredUsername = _desiredUsername;
	
	static toJson = function() {
		return self;
	}
	
	static fromJson = function(json) {
		Assert.cond(is_struct(json));
		Assert.cond(is_string(json[$ "desiredUsername"]));
		
		return new C2S_ConnectBeginHandshake(json.desiredUsername);
	}
}

new C2S_ConnectBeginHandshake("");

/**
 * Information sent from the server to a newly connecting client.
 * 
 * @param {Id.Socket} _yourId Unique identifier assigned by the server for this client.
 * @param {Array<Struct>} _clientList List of client IDs in the server.
 */
function S2C_ConnectSuccess(_yourId, _clientList) : Message() constructor {
	yourId = _yourId;
	clientList = _clientList;
	
	static toJson = function() {
		return self;
	}
	
	static fromJson = function(json) {
		Assert.cond(is_struct(json));
		Assert.cond(is_real(json[$ "yourId"]));
		Assert.cond(is_array(json[$ "clientList"]));
		
		array_foreach(json[$ "clientList"], function(clientInfo) {
			Assert.cond(is_struct(clientInfo));
			Assert.cond(is_real(clientInfo.id));
			Assert.cond(is_string(clientInfo[$ "username"]) or is_undefined(clientInfo[$ "username"]));
		});
		
		return new S2C_ConnectSuccess(json.yourId, json.clientList);
	}
}

new S2C_ConnectSuccess(0, []);
