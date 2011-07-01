#!/bin/sh

echo '# Load ZFS kernel module'
kldload /mnt2/boot/kernel/opensolaris.ko
kldload /mnt2/boot/kernel/zfs.ko

echo '# clean ad4'
zpool import -f sys_tank
zpool destroy sys_tank

gpart delete -i 1 ad4
gpart delete -i 2 ad4
gpart delete -i 3 ad4
gpart destroy ad4

echo ' # create gpt disk'
gpart create -s gpt ad4

echo '# Create the boot, swap and zfs partitions'
gpart add -s 64K -t freebsd-boot ad4
gpart add -s 442G -t freebsd-zfs -l disk0 ad4
gpart add -t freebsd-swap -l swap0 ad4

echo '# Install the Protected MBR (pmbr) and gptzfsboot loader'
gpart bootcode -b /mnt2/boot/pmbr -p /mnt2/boot/gptzfsboot -i 1 ad4

echo '# Create ZFS Pool sys_tank'
mkdir /boot/zfs
zpool create sys_tank /dev/gpt/disk0
zpool set bootfs=sys_tank sys_tank

echo '# Create ZFS filesystem hierarchy'
zfs set checksum=fletcher4                                      sys_tank

zfs create                                                      sys_tank/usr
zfs create                                                      sys_tank/usr/home
zfs create -o compression=lzjb                  -o setuid=off   sys_tank/usr/ports
zfs create -o compression=off   -o exec=off     -o setuid=off   sys_tank/usr/ports/distfiles
zfs create -o compression=off   -o exec=off     -o setuid=off   sys_tank/usr/ports/packages
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   sys_tank/usr/src
zfs create                                                      sys_tank/var
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   sys_tank/var/crash
zfs create                      -o exec=off     -o setuid=off   sys_tank/var/db
zfs create -o compression=lzjb  -o exec=on      -o setuid=off   sys_tank/var/db/pkg
zfs create                      -o exec=off     -o setuid=off   sys_tank/var/empty
zfs create -o compression=lzjb  -o exec=off     -o setuid=off   sys_tank/var/log
zfs create -o compression=gzip  -o exec=off     -o setuid=off   sys_tank/var/mail
zfs create                      -o exec=off     -o setuid=off   sys_tank/var/run
zfs create -o compression=lzjb  -o exec=on      -o setuid=off   sys_tank/var/tmp
zfs create -o compression=on    -o exec=on      -o setuid=off   sys_tank/tmp

chmod 1777 /sys_tank/tmp
chmod 1777 /sys_tank/var/tmp

echo '# Install FreeBSD to sys_tank'
cd /dist/8.2-RELEASE
export DESTDIR=/sys_tank
for dir in base catpages dict doc games info lib32 manpages ports; \
          do (cd $dir ; ./install.sh) ; done
cd src ; ./install.sh all
cd ../kernels ; ./install.sh generic
cd /sys_tank/boot ; cp -Rlp GENERIC/* /sys_tank/boot/kernel/

echo '# Make /var/empty readonly'
zfs set readonly=on sys_tank/var/empty

echo '# import data_tank'
zpool import -f data_tank

mkdir /sys_tank/home



echo '# Install zpool.cache to the ZFS filesystem'
cp /boot/zfs/zpool.cache /sys_tank/boot/zfs/zpool.cache

# export LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/mnt2/lib 

echo '# reste à faire :'
echo '# chroot /sys_tank'
echo '# passwd'
echo '# cd /etc/mail'
echo '# make aliases'
echo '# exit'
