
#macro EVENT_EMITTER_DEBUG_ASSERTIONS true

/**
 * @param {String} ... Names of the events emitted by this emitter.
 */
function EventEmitter() constructor {
	
	self.listeners = {};
	self.oneTimeListeners = {};
	
	for (var i = 0; i < argument_count; i ++) {
		self.listeners[$ argument[i]] = [];
		self.oneTimeListeners[$ argument[i]] = [];
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
	 * Listen to a single emission of a given event.
	 * 
	 * @template T
	 * @param {String} event The event to listen to.
	 * @param {Function} listener The subscribing callback.
	 */
	static once = function(event, listener) {
		
		self.on(event, listener);
		
		var oneTimeListens = self.oneTimeListeners[$ event];
		array_push(oneTimeListens, listener);
		
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
		var oneTimeListens = self.oneTimeListeners[$ event];
		
		if (EVENT_EMITTER_DEBUG_ASSERTIONS && is_undefined(eventListeners)) {
			throw new Err($"Debug Assertion: Cannot unsubscribe from non-existent event `{event}`");
		}
		
		var index = array_get_index(eventListeners, listener);
		
		if (index < 0) {
			return false;
		}
		
		var oneTimeIndex = array_get_index(eventListeners, listener);
		
		if (oneTimeIndex >= 0) {
			array_delete(oneTimeListens, oneTimeIndex, 1);
		}
		
		array_delete(eventListeners, index, 1);
		return true;
		
	};
	
	/**
	 * Emit the given event with the given arguments.
	 * 
	 * @param {String} event The event to emit.
	 * @param {Any} ... Data to be emitted with the event.
	 */
	static emit = function(event) {
		
		var eventListeners = self.listeners[$ event];
		var oneTimeListens = self.oneTimeListeners[$ event];
		
		if (EVENT_EMITTER_DEBUG_ASSERTIONS && is_undefined(eventListeners)) {
			throw new Err($"Debug Assertion: Cannot emit non-existent event `{event}`");
		}
		
		if (argument_count == 2) {
			return array_foreach(eventListeners, method({ data: argument[1], oneTimeListens}, function(listener) {
				
				listener(data);
				
				var oneTimeIndex = array_get_index(oneTimeListens, listener);
		
				if (oneTimeIndex >= 0) {
					array_delete(oneTimeListens, oneTimeIndex, 1);
				}
				
			}));
		}
		
		var data = array_create(argument_count - 1);
		
		for (var i = 1; i < argument_count; i ++) {
			data[i - 1] = argument[i];
		}
		
		return array_foreach(eventListeners, method({ data, oneTimeListens }, function(listener) {
			
			if (is_method(listener)) {
				method_call(listener, data);
			} else {
				script_execute_ext(listener, data);
			}
			
			var oneTimeIndex = array_get_index(oneTimeListens, listener);
		
			if (oneTimeIndex >= 0) {
				array_delete(oneTimeListens, oneTimeIndex, 1);
			}
			
		}));
		
	};
	
}
