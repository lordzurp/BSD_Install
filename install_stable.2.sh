#!/bin/sh


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
ee /etc/ssh/sshd_config

# reboot
shutdown -r now