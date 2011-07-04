#!/bin/sh

#cd $scripts
cd /usr/scripts

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_zfs.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_conf.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_userland.sh

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_scripts.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_kernel.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_world.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_userland.sh

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/import_user.webmin
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/import_group.webmin

cd /usr/scripts/userland

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/avahi.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/kit_AMP.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/netatalk.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/samba.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/subsonic.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/transmission.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/virtualbox.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/webmin.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/X.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/


chmod -R +x *