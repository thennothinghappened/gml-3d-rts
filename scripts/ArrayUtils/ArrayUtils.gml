
/**
 * Delete the first occurence of the given value in the array.
 * 
 * Returns whether successful (the entry existed.)
 * 
 * @param {Array} array
 * @param {Any} value
 * @returns {Bool}
 */
function array_delete_first(array, value) {
	var index = array_get_index(array, value);
	
	if (index < 0) {
		return false;
	}
	
	array_delete(array, index, 1);
	return true;
}
