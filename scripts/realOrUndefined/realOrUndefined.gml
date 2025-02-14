
/**
 * Convert the given string to a number, or return undefined if it cannot be.
 * 
 * @param {String} string
 * @returns {Real|Undefined}
 */
function realOrUndefined(string) {
	try {
		return real(string);
	} catch (_) {
		return undefined;
	}
}
