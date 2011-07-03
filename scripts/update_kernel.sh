#!/bin/sh

# Clean
cd /usr/src
make clean

# Récuperer les sources à jour
cvsup stable-supfile

# Compile le nouveau noyau
make buildkernel -j4 KERNCONF=zurpatator2
make installkernel KERNCONF=zurpatator2

# reboot
echo ""
echo ""
echo "reboot necessaire (shutdown -r now) !!"
echo ""
echo ""