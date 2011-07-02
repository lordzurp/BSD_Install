#!/bin/sh
#
# PROVIDE: utility
# REQUIRE: DAEMON
# KEYWORD: shutdown

#
# DO NOT CHANGE THESE DEFAULT VALUES HERE
# SET THEM IN THE /etc/rc.conf FILE
#
vboxtool_enable=${vboxtool_enable-"NO"}
vboxtool_flags=${vboxtool_flags-""}
vboxtool_pidfile=${vboxtool_pidfile-"/var/run/vboxtool.pid"}

. /etc/rc.subr

name="vboxtool"
rcvar=`set_rcvar`
command="/usr/local/bin/vboxtool autostart"

load_rc_config $name

pidfile="${utility_pidfile}"

start_cmd="echo \"Starting ${name}.\"; /usr/bin/nice -5 ${command} ${vboxtool_flags} ${command_args}"

