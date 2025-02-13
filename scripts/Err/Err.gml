
/**
 * Generic Error type as analogue of GM's `Struct.Exception`.
 * 
 * @param {String} msg The readable message for this error.
 * @param {Struct.Err|Struct.Exception|Undefined} [cause] The error which caused this one, if any.
 * @param {Array<String>|Undefined} [__stacktrace] The stacktrace of this error, 
 */
function Err(msg, cause = undefined, __stacktrace = undefined) constructor {
	
	/**
	 * Create an instance of an `Err` from the given argument.
	 * 
	 * @param {Any} err The source error.
	 * @returns {Struct.Err|Undefined}
	 */
	static from = function(err) {
		
		if (is_undefined(err)) {
			return undefined;
		}
		
		if (is_string(err)) {
			return new Err(err);
		}
		
		if (is_struct(err)) {
			
			if (is_instanceof(err, Err)) {
				return variable_clone(err);
			}
			
			var message = err[$ "message"];
			var stacktrace = err[$ "stacktrace"];
			
			if (is_string(message) && is_array(stacktrace)) {
				return new Err(message, undefined, stacktrace);
			}
			
		}
		
		return new Err(string(err));
		
	}
	
	/**
	 * Write the readable stringified version of this error.
	 * @returns {String}
	 */
	static toString = function() {
		
		var str = "Error";
		
		if (object_exists(self.object)) {
			str += $" in object {object_get_name(self.object)}";
		}
		
		str +=
			$": {self.message}" +
			$"\n  at {string_join_ext("\n  at ", self.stacktrace)}" +
			(!is_undefined(self.cause) ? $"\nCause: {self.cause}" : "");
		
		return str;
		
	}
	
	/**
	 * Return a version of this error formatted as a regular GML error.
	 * @returns {String}
	 */
	static format = function() {
		
		static header = "___________________________________________";
		static divider = "############################################################################################";
		
		var object_name = object_exists(self.object)
			? object_get_name(self.object)
			: "undefined";
		
		return $"{header}\n{divider}\nERROR\nfor object {object_name}:\n\n{self.message}\n at {string_join_ext("\n at ", self.stacktrace)}\nCause: {self.cause}\n{divider}\n";
		
	}
	
	/** Array of characters considered whitespace when trimming the error message. */
	static __whitespace = ["\n"];
	
	if (!is_undefined(__stacktrace)) {
		
		// Assign the stacktrace we were given, as we must be assigning from an Exception.
		self.stacktrace = __stacktrace;
		
	} else {
		
		// Get the callstack minus the entry for us getting it.
		self.stacktrace = debug_get_callstack();
		array_delete(self.stacktrace, 0, 1);
		
	}
	
	/** The readable message for this error. */
	self.message = string_trim(msg, Err.__whitespace);
	
	/** The error that caused this one, if any. */
	self.cause = Err.from(cause);
	
	/** The object this error occurred in. */
	self.object = undefined;
	
	if (instance_exists(other)) {
		self.object = other[$ "object_index"];
	}
	
	/** The full error message. */
	self.longMessage = self.toString();
	
}

// Setup the static struct.
new Err("");
