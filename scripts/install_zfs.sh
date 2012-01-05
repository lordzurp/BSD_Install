#!/bin/sh

echo '#1 Make /tmp writable'
umount /dev/md1
mdmfs -s 512M md1 /tmp

echo '#2 Load ZFS kernel module'
kldload /mnt2/boot/kernel/opensolaris.ko
kldload /mnt2/boot/kernel/zfs.ko

echo '#3 clean ada0'
#zpool import -f sys-tank
#zpool destroy sys-tank

gpart delete -i 1 ada0
gpart delete -i 2 ada0
gpart delete -i 3 ada0
gpart destroy ada0

echo '#4 create gpt disk'
gpart create -s gpt ada0

echo '# Create the boot and zfs partitions'
gpart add -b 34 -s 64K -t freebsd-boot ada0
gpart add -t freebsd-zfs -l RE2-500go ada0

echo '# Install the Protected MBR (pmbr) and gptzfsboot loader'
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada0

echo '#5 Create ZFS Pool sys-tank'
mkdir /boot/zfs
zpool create -f sys-tank /dev/gpt/RE2-500go
zpool set bootfs=sys-tank sys-tank
zfs set checksum=fletcher4 sys-tank
zfs set mountpoint=/mnt sys-tank

echo '#6 At this point export and import the pool while preserving zroot.cache in /tmp.'
zpool export sys-tank
zpool import -o cachefile=/tmp/zpool.cache sys-tank

echo '#7 Create ZFS filesystem hierarchy'
zfs create                                                      sys-tank/usr
zfs create                                                      sys-tank/usr/home
zfs create -o compression=lzjb                  -o setuid=off   sys-tank/usr/ports
zfs create -o compression=off   -o exec=off     -o setuid=off   sys-tank/usr/ports/distfiles
zfs create -o compression=off   -o exec=off     -o setuid=off   sys-tank/usr/ports/packages
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   sys-tank/usr/src
zfs create                                                      sys-tank/var
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   sys-tank/var/crash
zfs create                      -o exec=off     -o setuid=off   sys-tank/var/db
zfs create -o compression=lzjb  -o exec=on      -o setuid=off   sys-tank/var/db/pkg
zfs create                      -o exec=off     -o setuid=off   sys-tank/var/empty
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   sys-tank/var/log
zfs create -o compression=gzip  -o exec=off     -o setuid=off   sys-tank/var/mail
zfs create                      -o exec=off     -o setuid=off   sys-tank/var/run
zfs create -o compression=lzjb  -o exec=on      -o setuid=off   sys-tank/var/tmp
zfs create -o compression=on    -o exec=on      -o setuid=off   sys-tank/tmp


chmod 1777 /mnt/tmp
cd /mnt ; ln -s usr/home home
chmod 1777 /mnt/var/tmp


echo '#8 Add swap space and disable checksums. In this case I add 4GB of swap.'

zfs create -V 24G sys-tank/swap
zfs set org.freebsd:swap=on sys-tank/swap
zfs set checksum=off sys-tank/swap


echo '# Install FreeBSD to sys-tank'
sh
cd /usr/freebsd-dist
export DESTDIR=/mnt
for file in base.txz lib32.txz kernel.txz doc.txz ports.txz src.txz;
do (cat $file | tar --unlink -xpJf - -C ${DESTDIR:-/}); done


cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache


echo '# Make /var/empty readonly'
zfs set readonly=on sys-tank/var/empty

echo '# import data_tank'
#mkdir /sys-tank/home
# zpool import -f data_tank

echo 'zfs_enable="YES"' >> /mnt/etc/rc.conf
echo 'zfs_load="YES"' >> /mnt/boot/loader.conf
echo 'vfs.root.mountfrom="zfs:sys-tank"' >> /mnt/boot/loader.conf
touch /mnt/etc/fstab

# (13) Unmount everything and fix mountpoints for system boot.

zfs set readonly=on sys-tank/var/empty
zfs umount -a
zfs set mountpoint=legacy sys-tank
zfs set mountpoint=/tmp sys-tank/tmp
zfs set mountpoint=/usr sys-tank/usr
zfs set mountpoint=/var sys-tank/var


echo '# Installe fstab, rc.conf et loader.conf'
# copy rc.conf
#cd /sys-tank/etc/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/rc.conf
# copy fstab
#cd /sys-tank/etc/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/fstab
# copy loader.conf
#cd /sys-tank/boot/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/loader.conf


echo '# Install zpool.cache to the ZFS filesystem'
#cp /boot/zfs/zpool.cache /sys-tank/boot/zfs/zpool.cache

# export LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/mnt2/lib 

# Install du script post_install
mkdir /mnt/usr/scripts
mkdir /mnt/usr/scripts/userland
cd /mnt/usr/scripts
fetch https://raw.github.com/lordzurp/Zurpatator2/master/scripts/update_scripts.sh
