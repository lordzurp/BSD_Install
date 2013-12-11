#!/bin/sh
#
# $FreeBSD: ports/emulators/virtualbox-ose-kmod/files/vboxnet.in,v 1.3 2010/03/27 00:12:58 dougb Exp $
#

# PROVIDE:	vboxnet
# REQUIRE:	FILESYSTEMS
# BEFORE:	netif
# KEYWORD:	nojail

#
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
# vboxnet_enable (bool):   Set to NO by default.
#               Set it to YES to load network related kernel modules on startup

. /etc/rc.subr

name="vboxtool"
rcvar=${name}_enable
start_cmd="vboxtool_start"

vboxtool_start()
{
	/usr/local/bin/vboxtool autostart
}


load_rc_config $name

: ${vboxtool_enable="NO"}

run_rc_command "$1"
