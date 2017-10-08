#! /bin/sh
#
# This script should be called by upssched via the CMDSCRIPT directive.
# 
# Here is a quick example to show how to handle a bunch of possible
# timer names with the help of the case structure.
#
# This script may be replaced with another program without harm.
#
# The first argument passed to your CMDSCRIPT is the name of the timer
# from your AT lines.

case $1 in
	COMMBAD)
		logger -t upssched-cmd "The UPS has been gone for awhile"
		;;
	ONBATT)
		logger -t upssched-cmd "The UPS is on battery"
		/usr/local/sbin/upsmon -c fsd
		;;
	LOWBATT)
		logger -t upssched-cmd "The UPS has low battery !"
		/usr/local/sbin/upsmon -c fsd
		;;
	*)
		logger -t upssched-cmd "Unrecognized command: $1"
		;;
esac

