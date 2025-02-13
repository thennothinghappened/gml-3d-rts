#! /bin/bash
#
# Multi-instance runner for testing multiplayer!
#

readonly ENABLED=true
readonly INSTANCE_COUNT=2
readonly PROJECT_NAME="$YYprojectName"
readonly PROJECT_DIR_NAME="$(echo "$PROJECT_NAME" | tr - _)"

set -e

debug_print() {
	echo "[InstanceRunner] $1"
}

if [ "$ENABLED" != true ]; then
	exit 0
fi

executable_command=""

# TODO: support non-VM runner.
# TODO: support other platforms.
case "$OSTYPE" in
	linux*)
		executable_command="
			cd '$HOME/GameMakerStudio2/vm/$PROJECT_DIR_NAME/' &&
			nohup './$PROJECT_DIR_NAME.AppImage'				\
				--appimage-extract-and-run						\
				-debugoutput '$HOME/GameMakerStudio2/debug.log'	\
				-output '$HOME/GameMakerStudio2/debug.log' &
		"
		;;

	*)
		debug_print "TODO!! No support for multiple instances yet."
		exit 0
		;;
esac

debug_print "Starting MP instances!"

for i in $(seq "$INSTANCE_COUNT"); do
	debug_print " -> Spawning instance $i"
	(eval $executable_command) &
done

debug_print "Reporting failure to stop Igor."

exit 1

