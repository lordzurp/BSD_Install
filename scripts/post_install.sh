#!/bin/sh

portsnap fetch
portsnap extract
portsnap upgrade
portsnap update

cd /usr/ports/x11/gnome2 ; make config-recursive ; make fetch-recursive
cd /usr/ports/emulators/virtualbox-ose ; make config-recursive ; make fetch-recursive

java
webmin --> /usr/local/lib/webmin/setup.sh

upgrade tout le system
http://www.cyberciti.biz/faq/freebsd-cvsup-update-system-applications/

http://www.cyberciti.biz/faq/howto-setup-freebsd-jail-with-ezjail/

http://www.activeobjects.no/subsonic/forum/viewtopic.php?t=3314

http://blogs.freebsdish.org/rpaulo/2008/11/15/freebsd-and-mac-os-x-a-happy-combination/

http://www.endeavoursofanengineer.com/blog/2010/05/08/installing-avahi-on-freebsd-2/

http://technet.microsoft.com/en-us/library/gg637877.aspx

