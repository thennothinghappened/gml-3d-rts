
/**
 * Information sent from the server to a newly connecting client.
 * 
 * @sealed May be one of `ServerJoinResponseSuccess`, or `ServerJoinResponseFailed`.
 */
function ServerJoinResponse() : Message() constructor
{
	static toJson = function()
	{
		abstract();
	}
	
	/**
	 * @returns {Struct.ServerJoinResponse}
	 */
	static fromJson = function(json)
	{
		Assert.cond(is_struct(json));
		Assert.cond(is_string(json[$ "kind"]));
		
		switch (json.kind)
		{
			case nameof(ServerJoinResponse_Success): return ServerJoinResponse_Success.fromJson(json);
			case nameof(ServerJoinResponse_Failed): return ServerJoinResponse_Failed.fromJson(json);
			default: throw $"Invalid message kind `{json.kind}`";
		}
	}
}

new ServerJoinResponse();

/**
 * The client has successfully joined the server.
 * This message gives the client the lobby information.
 * 
 * @param {Array<String>} playerNames
 */
function ServerJoinResponse_Success(playerNames) : ServerJoinResponse() constructor
{
	self.playerNames = playerNames;
	
	static toJson = function()
	{
		return {
			kind: instanceof(self),
			playerNames
		};
	}
	
	static fromJson = function(json)
	{
		Assert.cond(is_struct(json));
		
		var playerNames = json[$ "playerNames"];
		Assert.cond(is_array(playerNames));
		Assert.cond(array_all(playerNames, is_string));
		
		return new ServerJoinResponse_Success(playerNames);
	}
}

/**
 * The client could not join the server.
 * 
 * @param {Enum.JoinRejectReason} reason Why joining was rejected
 */
function ServerJoinResponse_Failed(reason) : ServerJoinResponse() constructor
{
	self.reason = reason;
	
	static toJson = function()
	{
		return {
			kind: instanceof(self),
			reason
		};
	}
	
	static fromJson = function(json)
	{
		Assert.cond(is_struct(json));
		
		var reason = json[$ "reason"];
		Assert.cond(is_numeric(reason));
		
		return new ServerJoinResponse_Failed(reason);
	}
	
	enum JoinRejectReason
	{
		/**
		 * The chosen username is taken by another player.
		 */
		NameTaken,
		
		/**
		 * The client and server are running different versions.
		 */
		VersionMismatch
	}
}
