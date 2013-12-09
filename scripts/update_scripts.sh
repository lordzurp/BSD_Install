#!/bin/sh

. /usr/scripts/bsd_flavour.conf


#cd $scripts
cd /usr/scripts

fetch $source_install/scripts/install_zfs.sh
fetch $source_install/scripts/post_install.sh
fetch $source_install/scripts/install_userland.sh
fetch $source_install/scripts/install_jail.sh

fetch $source_install/scripts/update_scripts.sh
fetch $source_install/scripts/update_kernel.sh
fetch $source_install/scripts/update_world.sh
fetch $source_install/scripts/update_userland.sh

# attention, ça effacera votre flavour personnalisé !
fetch $source_install/scripts/bsd_flavour.conf
echo "pwet"

#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/import_user.webmin
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/import_group.webmin

#cd /usr/scripts/userland

#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/avahi.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/kit_AMP.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/netatalk.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/samba.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/subsonic.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/transmission.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/virtualbox.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/webmin.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/X.sh
#fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/userland/


chmod -R +x *