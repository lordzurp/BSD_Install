#!/bin/sh

############################
### Configuration du système
############################

# set root password
passwd root

# Mail
cd /etc/mail
make aliases

# Time Zone
cd /etc/
ln -s /usr/share/zoneinfo/Europe/Paris localtime

# Sshd
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

# Installe les packages utiles
pkg_add -r pdksh bash wget gmake gcc46 lftp lynx mc portaudit screen cvsup-without-gui

# Shells
cd ~/
setenv PACKAGESITE ftp://ftp.free.fr/mirrors/ftp.freebsd.org/ports/amd64/packages-8-stable/Latest/
cd /bin/
ln -s /usr/local/bin/ksh
ln -s /usr/local/bin/bash
echo '/bin/ksh' >> /etc/shells
echo '/bin/bash' >> /etc/shells

# GNU Screen
cd /usr/local/etc/
mv screenrc screenrc.dist
wget https://raw.github.com/lordzurp/Zurpatator2/master/misc/screenrc
cd /etc/
ln -s /usr/local/etc/screenrc
cd ~/
wget https://raw.github.com/lordzurp/Zurpatator2/master/misc/.screenrc
screen

# cvsup
cp /usr/share/examples/cvsup/stable-supfile /usr/src/
cp /usr/share/examples/cvsup/ports-supfile /usr/src/
echo 'Edit du fichier /usr/src/stable-supfile'
echo 'modifier la ligne :'
echo 'default host=cvsup1.fr.FreeBSD.org'
read -p "Appuyer sur une touche pour continuer ..."
ee /usr/src/stable-supfile
ee /usr/src/ports-supfile


################################
### Copie des fichiers de config
################################
# /etc/
cd /etc/
cp rc.conf rc.conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/sys_conf/rc.conf
cp fstab fstab.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/sys_conf/fstab
cp sysctl.conf sysctl.conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/sys_conf/sysctl.conf
# /boot/
cd /boot/
cp loader.conf loader.conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/sys_conf/loader.conf
# Kernel
cd /usr/src/sys/amd64/conf/
fetch http://chez.tinico.free.fr/docs/bsd.conf/zurpatator2

########################
### Config système
########################
echo "CPYTYPE?= athlon64" >> /etc/make.conf

########################
### Installe les scripts
########################
mkdir /usr/scripts
cd /usr/scripts
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_scripts.sh
chmod +x update_scripts.sh
#setenv scripts /usr/scripts
/usr/scripts/update_scripts.sh


###################
### Security Tweaks
###################
chmod 640 /var/log/messages




#java
#webmin --> /usr/local/lib/webmin/setup.sh

#upgrade tout le system


