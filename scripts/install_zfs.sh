#!/bin/sh

echo " #############################################################################"
echo " # ce script doit etre edite AVANT de le lancer, pour configurer vos disques #"
echo " # sinon, votre disque sera efface et votre chat brulera votre maison        #"
echo " #############################################################################"
echo ""
echo "la suite dans 10s ..."

sleep 10

########################
# Definition des variables
########################

# Nom du pool système
sys_tank="sys_tank"


########################
# Debut de l'install
########################
echo " c'est parti !"
date -u > /tmp/start_time

# Inutile si disque deja partitionné
# création de la table GPT sur le disque ada2
#gpart create -s gpt ada2
# création d une partition de boot, début au secteur 34, taille 512 secteurs
#gpart add -b 34 -s 512 -t freebsd-boot ada2
# création de la partition système, début au secteur 2048 (4k ready), 20G, label system
#gpart add -b 2048 -s 20G-t freebsd-zfs -l system ada2

# utile ...
# on nettoie le precedent pool
zpool import -f -o altroot=/mnt $sys_tank
zpool destroy -f $sys_tank
# ça, c'etait dans le howto ...
mkdir /boot/zfs
# on crée un dataset ZFS nommé $sys_tank sur la partition gpt/system
zpool create $sys_tank /dev/gpt/system
# on change le checksum
zfs set checksum=fletcher4 $sys_tank
# on active la deduplication
zfs set dedup=on $sys_tank
# on desactive la compression par défaut
zfs set compression=off $sys_tank

# on export et réimporte le pool dans /mnt, en préservant zroot.cache dans /tmp
zpool export $sys_tank
zpool import -o cachefile=/tmp/zpool.cache -o altroot=/mnt $sys_tank

# on crée l'arboréscence ZFS
# on installe le système dans $sys_tank/root, ça permet de changer le /root si besoin (upgrade ...)
zfs create                                                      $sys_tank/root
zfs create                                                      $sys_tank/home
zfs create                                                      $sys_tank/usr
zfs create                                                      $sys_tank/usr/local
zfs create -o compression=lzjb                  -o setuid=off   $sys_tank/usr/ports
zfs create -o compression=off   -o exec=off     -o setuid=off   $sys_tank/usr/ports/distfiles
zfs create -o compression=off   -o exec=off     -o setuid=off   $sys_tank/usr/ports/packages
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   $sys_tank/usr/src
zfs create -o compression=on                    -o setuid=off   $sys_tank/usr/jails
zfs create                                                      $sys_tank/var
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   $sys_tank/var/crash
zfs create                      -o exec=off     -o setuid=off   $sys_tank/var/db
zfs create -o compression=lzjb  -o exec=on      -o setuid=off   $sys_tank/var/db/pkg
zfs create                      -o exec=off     -o setuid=off   $sys_tank/var/empty
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   $sys_tank/var/log
zfs create -o compression=gzip  -o exec=off     -o setuid=off   $sys_tank/var/mail
zfs create                      -o exec=off     -o setuid=off   $sys_tank/var/run
zfs create -o compression=lzjb  -o exec=on      -o setuid=off   $sys_tank/var/tmp
zfs create -o compression=on    -o exec=on      -o setuid=off   $sys_tank/tmp

# on crée le /home dans le meme pool --> config disque unique
zfs create -o compression=on    -o exec=on      -o setuid=off	-o dedup=off   $sys_tank/home

# on définit l'emplacement de la racine pour le boot
zpool set bootfs=$sys_tank/root $sys_tank

# /var/empty en lecture seule
zfs set readonly=on $sys_tank/var/empty

# swap de 16Go, sans dedup ni checksum
zfs create -V 4G $sys_tank/swap
zfs set org.freebsd:swap=on $sys_tank/swap
zfs set checksum=off $sys_tank/swap
zfs set dedup=off $sys_tank/swap

# on umount le tout et on refait les points de montage propres
zfs umount -a
zfs set mountpoint=none $sys_tank
zfs set mountpoint=/ $sys_tank/root
zfs set mountpoint=/tmp $sys_tank/tmp
zfs set mountpoint=/home $sys_tank/home
zfs set mountpoint=/usr $sys_tank/usr
zfs set mountpoint=/var $sys_tank/var

# on export et importe le pool
zpool export $sys_tank
zpool import -o cachefile=/tmp/zpool.cache -o altroot=/mnt $sys_tank

chmod 1777 /mnt/tmp
chmod 1777 /mnt/var/tmp

# Install de FreeBSD dans $sys_tank/root, monté sur /mnt
cd /usr/freebsd-dist
export DESTDIR=/mnt
for file in base.txz lib32.txz kernel.txz doc.txz ports.txz src.txz;
do (cat $file | tar --unlink -xpvJf - -C ${DESTDIR:-/}); done

# on remet le cache zfs
cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache

# Installe fstab, rc.conf sysctl.conf, make.conf et loader.conf, après backup

cp /mnt/etc/rc.conf /mnt/etc/rc.conf.dist
cp /mnt/etc/sysctl.conf /mnt/etc/sysctl.conf.dist
cp /mnt/boot/loader.conf /mnt/boot/loader.conf.dist
cp /tmp/start_time /mnt/root/start_time

touch /mnt/etc/fstab


########################
### /etc/rc.conf
########################
cat << EOF > /mnt/etc/rc.conf
# FreeBSD /etc/rc.conf

#########
# Systeme
#########
zfs_enable="YES"
#amd_enable="YES"
#acpi_enable="YES"
#apm_enable="YES"
#apmd_enable="YES"
dbus_enable="YES"
hald_enable="YES"

syslogd_enable="YES"
syslogd_flags="-s -b 127.0.0.1"

# empeche le système de biper comme un sourd
allscreens_kbdflags="-b visual"

# Set dumpdev to “AUTO" to enable crash dumps, “NO" to disable
dumpdev="AUTO"

##############
# Secure Tips
##############
clear_tmp_enable="YES"

##############
# Network Conf
##############
ifconfig_em1="up DHCP"
ifconfig_em1_alias0="inet 10.0.0.1/24" # ip du systeme de base

hostname="hawk.zurp.me"
tcp_extensions="YES"

#########
# Locales
#########
keymap="fr.iso.acc"

##########
# Services
##########
inetd_enable="NO"
logrotate_enable="YES"
sshd_enable="YES"

EOF


########################
### /etc/sysctl.conf
########################
cat << EOF > /mnt/etc/sysctl.conf
# $FreeBSD: src/etc/sysctl.conf

#security.bsd.see_other_uids=0
kern.module_path=/boot/kernel;/boot/modules;/usr/local/modules

net.inet.tcp.sendbuf_max=16777216
net.inet.tcp.recvbuf_max=16777216
kern.ipc.maxsockbuf=8192000
net.inet.tcp.rfc1323=1
net.inet.tcp.sack.enable=1
#net.inet.tcp.inflight.enable=0
net.inet.tcp.sendspace=1024000
net.inet.tcp.recvspace=1024000
net.inet.udp.recvspace=1024000
security.jail.allow_raw_sockets=1
net.inet.ip.forwarding=1

EOF


########################
### /boot/loader.conf
########################
cat << EOF > /mnt/boot/loader.conf
# FreeBSD /boot/loader.conf

autoboot_delay="3"

# Kernel tunables
kern.maxdsiz="100000000"        # Set the max data size

zfs_load="YES"
ahci_load="YES"
vboxdrv_load="YES"
vfs.root.mountfrom="zfs:$sys_tank/root"

cd9660_load="YES"        # ISO 9660 filesystem

EOF


########################
### /etc/ssh/sshd_config
########################
cd /mnt/etc/ssh/
mv sshd_config sshd_config.dist
sed '/^$/d; /^#/d' sshd_config.dist > sshd_config
cat >> sshd_config <<EOF9
Port 22
ListenAddress 10.0.0.1
Protocol 2
AllowGroups wheel
PermitRootLogin yes
EOF9


############################
#bootcode zfs
############################
echo " Editez cette partie du script pour l adapter à votre config !"
echo " par defaut, installation du bootcode se fait sur ada2"
echo ""
echo "la suite dans 10s ..."
sleep 10

gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptzfsboot -i 1 ada2

############################
# Install du script post_install
############################
mkdir /mnt/usr/scripts
mkdir /mnt/usr/scripts/userland
cd /mnt/usr/scripts
fetch http://81.65.119.199/zurp/update_scripts.sh
chmod +x update_scripts.sh


############################
### dummy_script auto-start
############################
# au reboot, on met à jour les scripts et on lance le post_install
echo '#!/bin/sh' > /mnt/etc/rc.d/dummy_script
echo '' >> /mnt/etc/rc.d/dummy_script
echo '. /etc/rc.subr' >> /mnt/etc/rc.d/dummy_script
echo '' >> /mnt/etc/rc.d/dummy_script
echo 'name="dummy"' >> /mnt/etc/rc.d/dummy_script
echo "start_cmd=\"\${name}_start\"" >> /mnt/etc/rc.d/dummy_script
echo "stop_cmd=\":\"" >> /mnt/etc/rc.d/dummy_script
echo '' >> /mnt/etc/rc.d/dummy_script
echo 'dummy_start()' >> /mnt/etc/rc.d/dummy_script
echo '{' >> /mnt/etc/rc.d/dummy_script
echo '     rm -f /etc/rc.d/dummy_script' >> /mnt/etc/rc.d/dummy_script
echo '     /usr/scripts/update_scripts.sh' >> /mnt/etc/rc.d/dummy_script
echo '     echo " "' >> /mnt/etc/rc.d/dummy_script
echo '     echo "install termine, lancer /usr/scripts/post_install.sh"' >> /mnt/etc/rc.d/dummy_script
# echo '     /usr/scripts/post_install.sh' >> /mnt/etc/rc.d/dummy_script
echo '     echo " "' >> /mnt/etc/rc.d/dummy_script
echo '}' >> /mnt/etc/rc.d/dummy_script
echo '' >> /mnt/etc/rc.d/dummy_script
echo "load_rc_config \"\$name\"" >> /mnt/etc/rc.d/dummy_script
echo "run_rc_command \"\$1\"" >> /mnt/etc/rc.d/dummy_script
echo '' >> /mnt/etc/rc.d/dummy_script

# on rend executable le dummy_script
chmod +x /mnt/etc/rc.d/dummy_script


############################
# reboot
############################
echo " "
echo " fin de install_zfs.sh"
echo " 20sec avant reboot"
echo " "
sleep 20
echo "time for reboot :)"
shutdown -r now
