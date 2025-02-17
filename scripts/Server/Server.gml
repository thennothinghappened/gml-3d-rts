
/**
 * A server for the game.
 * 
 * @param {Struct.NetworkServer} networkServer The underlying server controller on the network.
 */
function Server(networkServer) constructor {
	
	CLASS_LOG;
	
	static procedureHandlers = {};
	
	self.jsonRpc = new JsonRpc(serverProcedures(), clientProcedures());
	self.clients = [];
	
	self.networkServer = networkServer;
	self.networkServer.events.on("connect", method(self, self.onNetConnect));
	self.networkServer.events.on("disconnect", method(self, self.onNetDisconnect));
	self.networkServer.events.on("data", method(self, self.onNetData));
	
	/**
	 * Begins listening on the network for clients.
	 * Returns whether the operation was successful.
	 * 
	 * @returns {Bool}
	 */
	static listen = function() {
		return self.networkServer.listen();
	}
	
	/**
	 * Dispose of this server.
	 * This method **MUST** be called to clean up the resources used by this server.
	 */
	static dispose = function() {
		self.networkServer.dispose();
	};
	
	/**
	 * Handle a client's connection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onNetConnect = function(client) {
		log.info($"New connection from `{client}`");
		array_push(self.clients, client);
	};
	
	/**
	 * Handle a client's disconnection.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 */
	static onNetDisconnect = function(client) {
		log.debug($"`{client}` is disconnecting");
		array_delete(self.clients, array_get_index(self.clients, client), 1);
	};
	
	/**
	 * Handle incoming data from a client.
	 * 
	 * @ignore
	 * @param {Id.Socket} client
	 * @param {Id.Buffer} buffer
	 */
	static onNetData = function(client, buffer) {
		
		var text = buffer_read(buffer, buffer_text);
		var json;
		
		log.debug($"Packet from client `{client}`: `{text}`");
		
		try {
			json = json_parse(text);
		} catch (_) {
			log.error(new Err("TODO: Failed to parse inbound message from client!"));
			return;
		}
		
		var request;
		
		try {
			request = self.jsonRpc.handleIncoming(json);
		} catch (err) {
			log.error(new Err("Error whilst handling incoming request", err));
			return;
		}
		
		if (!is_instanceof(request, JsonRpcIncomingRequest)) {
			return;
		}
		
		var procedureHandler = procedureHandlers[$ request.procedure.name];
		procedureHandler(client, request);
		
	};
	
	/**
	 * @param {Id.Socket} client
	 * @param {Struct.JsonRpcIncomingRequest} request
	 */
	static onJoin = function(client, request) {
		
		var desiredUsername = request.params.desiredUsername;
		log.info($"Client `{client}` joining with username {desiredUsername}");
		
		self.networkServer.sendText(client, json_stringify(self.jsonRpc.createResponse(request,
			new ServerJoinInfo(
				client,
				self.clients
			)
		)));
		
	};
	
	if (struct_names_count(procedureHandlers) == 0) {
		procedureHandlers[$ serverProcedures.join.name] = self.onJoin;
	}
	
}

/**
 * Obtain the list of procedures on a game server.
 * @pure
 */
function serverProcedures() {
	
	static join = new JsonRpcProcedure("join", ClientJoinInfo, ServerJoinInfo);
	
	static list = [
		join
	];
	
	return list;
	
}
