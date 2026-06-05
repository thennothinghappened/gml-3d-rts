
/**
 * Various code state assertions.
 */
function Assert() {
	/**
	 * Assert that the given condition is `true`.
	 * 
	 * @param {Bool} condition The condition to assert `true`.
	 * @param {String|Function|Undefined} [message] Optional message to explain the assertion.
	 */
	static cond = function(condition, message = undefined) {
		if (!condition) {
			var messageString = "condition was `false`.";
			
			if (is_string(message)) {
				messageString = message;
			} else if (is_callable(message)) {
				messageString = message();
			}
			
			throw new Err($"Assertion Failed: {messageString}");
		}
	}
	
	/**
	 * Assert that `lhs` is equal to `rhs`.
	 * 
	 * @param {Any} lhs
	 * @param {Any} rhs
	 */
	static eq = function(lhs, rhs) {
		if (!__checkEquality(lhs, rhs)) {
			throw new Err($"Assertion Failed: {lhs} should equal {rhs}");
		}
	}
	
	/**
	 * Assert that `lhs` is not equal to `rhs`.
	 * 
	 * @param {Any} lhs
	 * @param {Any} rhs
	 */
	static neq = function(lhs, rhs) {
		if (__checkEquality(lhs, rhs)) {
			throw new Err($"Assertion Failed: {lhs} should not equal {rhs}");
		}
	}
	
	/**
	 * Assert that the provided value is not undefined.
	 * 
	 * @param {Any} value
	 */
	static notUndefined = function(value) {
		if (value == undefined) {
			throw new Err("Assertion failed: value should not be `undefined`");
		}
	}
	
	/**
	 * Check if `lhs` is equal to `rhs` by value, rather than by reference.
	 * 
	 * @ignore
	 * @pure
	 * @param {Any} lhs
	 * @param {Any} rhs
	 * @returns {Bool}
	 */
	static __checkEquality = function(lhs, rhs) {
		if (lhs == rhs) {
			return true;
		}
		
		if (is_array(lhs) and is_array(rhs)) {
			return array_equals(lhs, rhs);
		}
		
		return false;
	}
}

Assert();
