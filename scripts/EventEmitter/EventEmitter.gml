
#macro EVENT_EMITTER_DEBUG_ASSERTIONS true

/**
 * @param {String} ... Names of the events emitted by this emitter.
 */
function EventEmitter() constructor {
	
	self.listeners = {};
	
	for (var i = 0; i < argument_count; i ++) {
		self.listeners[$ argument[i]] = [];
	}
	
	/**
	 * Start listening to the given event.
	 * 
	 * @template T
	 * @param {String} event The event to listen to.
	 * @param {Function} listener The subscribing callback.
	 */
	static on = function(event, listener) {
		
		var eventListeners = self.listeners[$ event];
		
		if (EVENT_EMITTER_DEBUG_ASSERTIONS && is_undefined(eventListeners)) {
			throw new Err($"Debug Assertion: Cannot subscribe to non-existent event `{event}`");
		}
		
		array_push(eventListeners, listener);
		
	};
	
	/**
	 * Stop listening to the given event.
	 * 
	 * @param {String} event The event to stop listening to.
	 * @param {Function} listener The subscribing callback.
	 * @returns {Bool} Whether the listener was removed.
	 */
	static off = function(event, listener) {
		
		var eventListeners = self.listeners[$ event];
		
		if (EVENT_EMITTER_DEBUG_ASSERTIONS && is_undefined(eventListeners)) {
			throw new Err($"Debug Assertion: Cannot unsubscribe from non-existent event `{event}`");
		}
		
		var index = array_get_index(eventListeners, listener);
		
		if (index < 0) {
			return false;
		}
		
		array_delete(eventListeners, index, 1);
		return true;
		
	};
	
	/**
	 * Emit the given event with the given arguments.
	 * 
	 * @param {String} event The event to emit.
	 * @param {Any} data Data to be emitted with the event.
	 */
	static emit = function(event, data) {
		
		var eventListeners = self.listeners[$ event];
		
		if (EVENT_EMITTER_DEBUG_ASSERTIONS && is_undefined(eventListeners)) {
			throw new Err($"Debug Assertion: Cannot emit non-existent event `{event}`");
		}
		
		array_foreach(eventListeners, method({ data }, function(listener) {
			listener(data);
		}));
		
	};
	
}
