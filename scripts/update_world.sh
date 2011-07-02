#!/bin/sh

# Clean
cd /usr/src
make clean

# Récuperer les sources à jour
cvsup stable-supfile

# Compile le nouveau monde
make buildworld -j4 
mergemaster -p
make installworld
make delete-old
make delete-old-libs
mergemaster -U -i
make delete-old-libs

portsnap fetch update
portsnap extract

# retype root passwd
passwd

# reconfigure sshd
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

# reboot
echo "reboot necessaire (shutdown -r now) !!"
