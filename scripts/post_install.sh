#!/bin/sh


############################
### Configuration du système
############################
# Time Zone
cd /etc/
ln -s /usr/share/zoneinfo/Europe/Paris localtime

# SSHd
cd /etc/ssh/
mv sshd_config sshd_config.dist
sed '/^$/d; /^#/d' sshd_config.dist > sshd_config
cat >> sshd_config <<EOF9
Port 22
ListenAddress 0.0.0.0
Protocol 2
AllowGroups wheel
PermitRootLogin yes
EOF9

# Shells
cd ~/
setenv PACKAGESITE ftp://ftp.free.fr/mirrors/ftp.freebsd.org/ports/amd64/packages-8-stable/Latest/
pkg_add -r pdksh bash wget lftp lynx mc portaudit screen
cd /bin/
ln -s /usr/local/bin/ksh
ln -s /usr/local/bin/bash
echo '/bin/ksh' >> /etc/shells
echo '/bin/bash' >> /etc/shells

#################################
### Copie des fichiers de  config
#################################
# /etc/
cd /etc/
cp rc.conf rc.conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/etc/rc.conf
cp fstab fstab.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/etc/fstab
# /boot/
cd /boot/
cp loader.conf loader.conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/loader.conf


########################
### Installe les scripts
########################
mkdir /usr/scripts
cd /usr/scripts
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_stable.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_stable.2.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_packages.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_conf.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/install_port.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/post_install.sh
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_bsd.sh
chmod +x install_*

cd /usr/local/etc/
mv screenrc screenrc.dist
wget pbraun.nethence.com/code/misc/screenrc
cd /etc/
ln -s /usr/local/etc/screenrc
cd ~/
wget pbraun.nethence.com/code/misc/.screenrc
screen

###################
### Security Tweaks
###################
chmod 640 /var/log/messages



portsnap fetch
portsnap extract
portsnap upgrade
portsnap update

cd /usr/ports/x11/gnome2 ; make config-recursive ; make fetch-recursive
cd /usr/ports/emulators/virtualbox-ose ; make config-recursive ; make fetch-recursive

java
webmin --> /usr/local/lib/webmin/setup.sh

upgrade tout le system


