
/**
 * Some sort of message that may be serialised and deserialised.
 */
function Message() constructor {
	
	/**
	 * Convert this message to serialisable JSON that may be safely stringified.
	 * @returns {Any}
	 */
	static toJson = function() {
		throw NotImplemented();
	};
	
	/**
	 * Deserialise this message from JSON.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the message is malformed.
	 * 
	 * @param {Any} json The serialised JSON data to parse.
	 * @returns {Struct.Message}
	 */
	static fromJson = function(json) {
		throw NotImplemented();
	};
	
}
