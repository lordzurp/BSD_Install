#! /bin/sh
#
# smartd warning script
#
# Copyright (C) 2012-14 Christian Franke <smartmontools-support@lists.sourceforge.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# You should have received a copy of the GNU General Public License
# (for example COPYING); If not, see <http://www.gnu.org/licenses/>.
#
# $Id: smartd_warning.sh.in 3932 2014-06-29 19:02:38Z chrfranke $
#

set -e

# Set by config.status
PACKAGE="smartmontools"
VERSION="6.5"
prefix="/usr/local"
sysconfdir="${prefix}/etc"
smartdscriptdir="${sysconfdir}"

# Default mailer
os_mailer="mail"

# Plugin directory (disabled if empty)
plugindir="${smartdscriptdir}/smartd_warning.d"

# Parse options
dryrun=
case $1 in
  --dryrun) dryrun=t; shift ;;
esac

if [ $# != 0 ]; then
  cat <<EOF
smartd $VERSION warning message script

Usage:
  export SMARTD_MAILER='Path to external script, empty for "$os_mailer"'
  export SMARTD_ADDRESS='Space separated mail adresses, empty if none'
  export SMARTD_MESSAGE='Error Message'
  export SMARTD_FAILTYPE='Type of failure, "EMailTest" for tests'
  export SMARTD_TFIRST='Date of first message sent, empty if none'
  #export SMARTD_TFIRSTEPOCH='time_t format of above'
  export SMARTD_PREVCNT='Number of previous messages, 0 if none'
  export SMARTD_NEXTDAYS='Number of days until next message, empty if none'
  export SMARTD_DEVICEINFO='Device identify information'
  #export SMARTD_DEVICE='Device name'
  #export SMARTD_DEVICESTRING='Annotated device name'
  #export SMARTD_DEVICETYPE='Device type from -d directive, "auto" if none'
  $0 [--dryrun]
EOF
  exit 1
fi

if [ -z "${SMARTD_ADDRESS}${SMARTD_MAILER}" ]; then
  echo "$0: SMARTD_ADDRESS or SMARTD_MAILER must be set" >&2
  exit 1
fi

# Get host and domain names
for cmd in 'hostname' 'echo "[Unknown]"'; do
  hostname=`eval $cmd 2>/dev/null` || continue
  test -n "$hostname" || continue
  break
done

dnsdomain=${hostname#*.}
if [ "$dnsdomain" != "$hostname" ]; then
  # hostname command printed FQDN
  hostname=${hostname%%.*}
else
  for cmd in  'echo'; do
    dnsdomain=`eval $cmd 2>/dev/null` || continue
    break
  done
  test "$dnsdomain" != "(none)" || dnsdomain=
fi

for cmd in 'domainname' 'echo'; do
  nisdomain=`eval $cmd 2>/dev/null` || continue
  break
done
test "$nisdomain" != "(none)" || nisdomain=

# Format subject
export SMARTD_SUBJECT="SMART error (${SMARTD_FAILTYPE-[SMARTD_FAILTYPE]}) detected on host: $hostname"

# Format message
fullmessage=`
  echo "This message was generated by the smartd daemon running on:"
  echo
  echo "   host name:  $hostname"
  echo "   DNS domain: ${dnsdomain:-[Empty]}"
  test -z "$nisdomain" ||
    echo "   NIS domain: $nisdomain"
  #test -z "$USERDOMAIN" ||
  #  echo "   Win domain: $USERDOMAIN"
  echo
  echo "The following warning/error was logged by the smartd daemon:"
  echo
  echo "${SMARTD_MESSAGE-[SMARTD_MESSAGE]}"
  echo
  echo "Device info:"
  echo "${SMARTD_DEVICEINFO-[SMARTD_DEVICEINFO]}"
  echo
  echo "For details see host's SYSLOG."
  if [ "$SMARTD_FAILTYPE" != "EmailTest" ]; then
    echo
    echo "You can also use the smartctl utility for further investigation."
    test "$SMARTD_PREVCNT" = "0" ||
      echo "The original message about this issue was sent at ${SMARTD_TFIRST-[SMARTD_TFIRST]}"
    case $SMARTD_NEXTDAYS in
      '') echo "No additional messages about this problem will be sent." ;;
      1)  echo "Another message will be sent in 24 hours if the problem persists." ;;
      *)  echo "Another message will be sent in $SMARTD_NEXTDAYS days if the problem persists." ;;
    esac
  fi
`

# Export message with trailing newline
export SMARTD_FULLMESSAGE="$fullmessage
"

# Run plugin scripts if requested
if test -n "$plugindir"; then
 case " $SMARTD_ADDRESS" in
  *\ @*)
    if [ -n "$dryrun" ]; then
      echo "export SMARTD_SUBJECT='$SMARTD_SUBJECT'"
      echo "export SMARTD_FULLMESSAGE='$SMARTD_FULLMESSAGE'"
    fi

    # Run ALL scripts if requested
    case " $SMARTD_ADDRESS " in
      *\ @ALL\ *)
        for cmd in "$plugindir"/*; do
          if [ -f "$cmd" ] && [ -x "$cmd" ]; then
            if [ -n "$dryrun" ]; then
              echo "$cmd </dev/null"
            else
              "$cmd" </dev/null
            fi
          fi
        done
        ;;
    esac

    # Run selected scripts
    addrs=$SMARTD_ADDRESS
    SMARTD_ADDRESS=
    for ad in $addrs; do
      case $ad in
        @ALL)
          ;;
        @?*)
          cmd="$plugindir/${ad#@}"
          if [ -f "$cmd" ] && [ -x "$cmd" ]; then
            if [ -n "$dryrun" ]; then
              echo "$cmd </dev/null"
            else
              "$cmd" </dev/null
            fi
          elif [ ! -e "$cmd" ]; then
            echo "$cmd: Not found" >&2
          fi
          ;;
        *)
          SMARTD_ADDRESS="${SMARTD_ADDRESS:+ }$ad"
          ;;
      esac
    done

    # Send email to remaining addresses
    test -n "$SMARTD_ADDRESS" || exit 0
    ;;
 esac
fi

# Send mail or run command
if [ -n "$SMARTD_ADDRESS" ]; then

  # Send mail, use platform mailer by default
  test -n "$SMARTD_MAILER" || SMARTD_MAILER=$os_mailer
  if [ -n "$dryrun" ]; then
    echo "exec '$SMARTD_MAILER' -s '$SMARTD_SUBJECT' $SMARTD_ADDRESS <<EOF
$fullmessage
EOF"
  else
    exec "$SMARTD_MAILER" -s "$SMARTD_SUBJECT" $SMARTD_ADDRESS <<EOF
$fullmessage
EOF
  fi

elif [ -n "$SMARTD_MAILER" ]; then

  # Run command
  if [ -n "$dryrun" ]; then
    echo "export SMARTD_SUBJECT='$SMARTD_SUBJECT'"
    echo "export SMARTD_FULLMESSAGE='$SMARTD_FULLMESSAGE'"
    echo "exec '$SMARTD_MAILER' </dev/null"
  else
    unset SMARTD_ADDRESS
    exec "$SMARTD_MAILER" </dev/null
  fi

fi
