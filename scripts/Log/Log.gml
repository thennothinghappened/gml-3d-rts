
#macro LOG __log_get()

/**
 * Whether to print game logs to STDOUT.
 */
#macro LOG_PRINT_TO_CONSOLE true

function __log_get() {
	static inst = new Log();
	return inst;
}

/**
 * Instance of a logger, that keeps track of game logs for us!
 * 
 * @param {Enum.LogSeverity} minPrintSeverity Minimum severity to bother printing to the console.
 */
function Log(minPrintSeverity = LogSeverity.Debug) constructor {
	
	enum LogSeverity {
		Debug,
		Info,
		Warn,
		Error,
		Fatal
	}
	
	enum LogEntryIndex {
		Time = 0,
		Severity = 1,
		Source = 2,
		Message = 3
	}
	
	self.minPrintSeverity = minPrintSeverity;
	self.entries = [];
	
	/**
	 * Return a readable stringified version of a log entry.
	 * 
     * @ignore
	 * @pure
	 * @param {Array} entry
	 */
	static __entry_tostring = function(entry) {
		
		static severityNames = [
			"Debug",
			"Info",
			"Warn",
			"Error",
			"FATAL"
		];
		
		var time = entry[LogEntryIndex.Time];
		var severity = severityNames[entry[LogEntryIndex.Severity]];
		var source = entry[LogEntryIndex.Source];
		var message = entry[LogEntryIndex.Message];
		
		return $"[{time}] [{severity}] [{source}] {message}";
		
	}
	
	/**
	 * Writes a message to the log.
	 * 
	 * @param {Enum.LogSeverity} severity
	 * @param {String} source
	 * @param {Any} message
	 */
	static log = function(severity, source, message) {
		
		var entry = array_create(4);
		entry[LogEntryIndex.Time] = current_time;
		entry[LogEntryIndex.Severity] = severity;
		entry[LogEntryIndex.Source] = source;
		entry[LogEntryIndex.Message] = message;
		
		array_push(self.entries, entry);
		
		if (LOG_PRINT_TO_CONSOLE && severity >= self.minPrintSeverity) {
			var text = self.__entry_tostring(entry);
			show_debug_message(text);
		}
		
	};
	
	/**
	 * Write a debug message to the log.
	 * 
	 * @param {String} source
	 * @param {Any} message
	 */
	static debug = function(source, message) {
		self.log(LogSeverity.Debug, source, message);
	}
	
	/**
	 * Write a info message to the log.
	 * 
	 * @param {String} source
	 * @param {Any} message
	 */
	static info = function(source, message) {
		self.log(LogSeverity.Info, source, message);
	}
	
	/**
	 * Write a warning message to the log.
	 * 
	 * @param {String} source
	 * @param {Any} message
	 */
	static warn = function(source, message) {
		self.log(LogSeverity.Warn, source, message);
	}
	
	/**
	 * Write a error message to the log.
	 * 
	 * @param {String} source
	 * @param {Any} message
	 */
	static error = function(source, message) {
		self.log(LogSeverity.Error, source, message);
	}
	
	/**
	 * Write a fatal message to the log.
	 * 
	 * @param {String} source
	 * @param {Any} message
	 */
	static fatal = function(source, message) {
		self.log(LogSeverity.Fatal, source, message);
	}
	
}

/**
 * A specific logging channel which has a given name. Basically just a wrapper that allows
 * you to avoid specifying the name over and over.
 * 
 * @param {String} name Unique name of this channel.
 */
function LogChannel(name) constructor {
	
	/** @ignore */
	self.name = name;
	
	/**
	 * Writes a message to the log.
	 * 
	 * @param {Enum.LogSeverity} severity
	 * @param {Any} message
	 */
	static log = function(severity, message) {
		LOG.log(severity, self.name, message);
	};
	
	/**
	 * Write a debug message to the log.
	 * 
	 * @param {Any} message
	 */
	static debug = function(message) {
		self.log(LogSeverity.Debug, message);
	}
	
	/**
	 * Write a info message to the log.
	 * 
	 * @param {Any} message
	 */
	static info = function(message) {
		self.log(LogSeverity.Info, message);
	}
	
	/**
	 * Write a warning message to the log.
	 * 
	 * @param {Any} message
	 */
	static warn = function(message) {
		self.log(LogSeverity.Warn, message);
	}
	
	/**
	 * Write a error message to the log.
	 * 
	 * @param {Any} message
	 */
	static error = function(message) {
		self.log(LogSeverity.Error, message);
	}
	
	/**
	 * Write a fatal message to the log.
	 * 
	 * @param {Any} message
	 */
	static fatal = function(message) {
		self.log(LogSeverity.Fatal, message);
	}
	
}
