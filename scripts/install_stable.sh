#!/bin/sh

#passwd
cd /etc/mail ; make aliases

# install cvsup
pkg_add -r cvsup-without-gui

# Clean
cd /usr/src
make clean

# recuperer les sources
cp /usr/share/examples/cvsup/stable-supfile /usr/src/
ee /usr/src/stable-supfile
cd /usr/src
cvsup stable-supfile

# restore config
cd /usr/src/sys/amd64/conf/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/zurpatator2

# Compile le nouveau noyau
cd /usr/src
make buildkernel -j4 KERNCONF=zurpatator2
make installkernel KERNCONF=zurpatator2

# reboot
shutdown -r now
