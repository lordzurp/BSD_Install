#!/bin/sh

#cd $scripts
cd /usr/scripts

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/post_install.sh

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_scripts.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_kernel.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_world.sh

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_conf.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_packages.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_port.sh

fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_bsd.sh

chmod +x *