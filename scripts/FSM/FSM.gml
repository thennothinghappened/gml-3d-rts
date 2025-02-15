
/**
 * @param {String} initialStateName Name of the state to execute first.
 */
function FSM(initialStateName) constructor {
	
	/**
	 * @ignore
	 */
	self.states = {};
	self.currentStateName = initialStateName;
	
	/**
	 * How long the current state has been running for, in frames.
	 * 
	 * @type {Real}
	 * @ignore
	 */
	self.timeInState = 0;
	
	/**
	 * Define a state with a given name. If this state is the specified initial state, the `enter`
	 * event for this state is immediately executed.
	 * 
	 * An `enter` event may return the name of another state. This is useful in such a case to define
	 * a "transition" between states, where an intermediate state only defines an `enter` method, which
	 * produces any necessary transitional side effects, and this method returns the name of the desired
	 * "end" state.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the name is taken.
	 * 
	 * @param {String} name
	 * @param {Struct} struct
	 */
	static state = function(name, state) {
		
		if (struct_exists(self.states, name)) {
			throw new Err($"State name `{name}` is taken");
		}
		
		// Bind state methods to the caller, instead of the struct.
		var eventNames = struct_get_names(state);
		
		for (var i = 0; i < array_length(eventNames); i ++) {
			var key = eventNames[i];
			state[$ key] = method(other, state[$ key]);
		}
		
		if (name == self.currentStateName) {
			var enter = state[$ "enter"];
			
			if (!is_undefined(enter)) {
				enter();
			}
		}
		
		self.states[$ name] = state;
		
	};
	
	/**
	 * Run the event of the given name, for the current state.
	 * 
	 * @param {String} name
	 * @returns {String}
	 */
	static run = function(name) {
		
		var currentState = self.states[$ self.currentStateName];
		var event = currentState[$ name];
		
		if (is_undefined(event)) {
			return self.currentStateName;
		}
		
		var newStateName = event(self.timeInState ++);
		
		if (is_undefined(newStateName)) {
			return self.currentStateName;
		}
		
		return self.change(newStateName);
		
	};
	
	/**
	 * Change to a new state.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the new state does not exist.
	 * 
	 * @param {String} newStateName
	 */
	static change = function(newStateName) {
		
		if (newStateName == self.currentStateName) {
			return self.currentStateName;
		}
		
		if (!struct_exists(self.states, newStateName)) {
			throw new Err($"Cannot change to non-existent state `{newStateName}`");
		}
		
		var currentState = self.states[$ self.currentStateName];
		
		self.currentStateName = newStateName;
		self.timeInState = 0;
		
		var leave = currentState[$ "leave"];
		
		if (!is_undefined(leave)) {
			leave();
		}
		
		var newState = self.states[$ self.currentStateName];
		var enter = newState[$ "enter"];
		
		if (!is_undefined(enter)) {

			var potentialNewStateName = enter();

			if (potentialNewStateName != undefined) {
				return self.change(potentialNewStateName);
			}

		}
		
		return newStateName;
		
	}
	
}
