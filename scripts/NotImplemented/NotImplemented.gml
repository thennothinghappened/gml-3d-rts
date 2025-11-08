
/**
 * An error caused by a function not being implemented yet!
 * @returns {Struct.Err}
 */
function NotImplemented() {
	return new Err("Not Yet Implemented!");
}

/**
 * This method is abstract and must be implemented by descendents.
 */
function abstract()
{
	throw "Abstract method.";
}
