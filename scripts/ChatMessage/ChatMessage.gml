
enum ChatMessageVisibility {
	Global,
	Team,
}

/// @pure
function ChatMessageVisibility_isValid(visibility) {
	static options = [ChatMessageVisibility.Global, ChatMessageVisibility.Team];
	return array_contains(options, visibility);
}

/**
 * Send a message to other players.
 * 
 * @param {Enum.ChatMessageVisibility} _visibility
 * @param {String} _message
 */
function C2S_ChatMessage(_visibility, _message) : Message() constructor {
	visibility = _visibility;
	message = _message;
	
	static toJson = function() {
		return self;
	}
	
	static fromJson = function(json) {
		Assert.cond(is_struct(json));
		Assert.cond(ChatMessageVisibility_isValid(json[$ "visibility"]));
		Assert.cond(is_string(json[$ "message"]));
		
		return new C2S_ChatMessage(json.visibility, json.message);
	}
}

new C2S_ChatMessage(ChatMessageVisibility.Global, "");

/**
 * A player has sent a message in the chat.
 * 
 * @param {Id.Socket} _senderId
 * @param {Enum.ChatMessageVisibility} _visibility
 * @param {String} _message
 */
function S2C_ChatMessageAdded(_senderId, _visibility, _message) : Message() constructor {
	senderId = _senderId;
	visibility = _visibility;
	message = _message;
	
	static toJson = function() {
		return self;
	}
	
	static fromJson = function(json) {
		Assert.cond(is_struct(json));
		Assert.cond(is_real(json[$ "senderId"]));
		Assert.cond(ChatMessageVisibility_isValid(json[$ "visibility"]));
		Assert.cond(is_string(json[$ "message"]));
		
		return new S2C_ChatMessageAdded(json.senderId, json.visibility, json.message);
	}
}

new S2C_ChatMessageAdded(0, ChatMessageVisibility.Global, "");
