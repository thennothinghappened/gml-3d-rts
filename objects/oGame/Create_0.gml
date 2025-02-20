/**
 * @desc Entry point for the game. Standard stuff.
 */

// We don't intend to use the built-in RNG for any game stuff, as it would make it very
// spooky trying to ensure it stays in-sync between players.
randomise();

/**
 * Temporary preferences storage struct.
 * TODO: This will be moved!
 */
self.prefs = {
	username: "orca",
	// TODO: This is not a valid format for a UUID.
	uuid: string(irandom_range(10000, 99999))
};

instance_create_depth(0, 0, 0, oNetworkManager);
instance_create_depth(0, 0, 0, oGui);
