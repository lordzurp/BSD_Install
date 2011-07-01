#!/bin/sh

cd $scripts
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_conf.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_packages.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_port.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_stable.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_stable.2.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/post_install.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_bsd.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_scripts.sh
chmod +x install_*