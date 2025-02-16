/**
 * @desc Entry point for the game. Standard stuff.
 */

/**
 * Temporary preferences storage struct.
 * TODO: This will be moved!
 */
self.prefs = {
	username: "orca"
};

instance_create_depth(0, 0, 0, oNetworkManager);
instance_create_depth(0, 0, 0, oGui);
