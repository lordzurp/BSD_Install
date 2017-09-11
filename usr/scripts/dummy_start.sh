#!/bin/sh

. /etc/rc.subr

name="dummy"
start_cmd="${name}_start"
stop_cmd=":"

dummy_start()
{
	rm -f /etc/rc.d/dummy_start.sh
	/usr/scripts/test.sh
}

load_rc_config $name
run_rc_command "$1"
