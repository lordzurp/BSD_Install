#!/bin/sh

# Install git, obviously
pkg install git
pkg install hub

# alias hub to git to enlarge your superpower
echo "alias git hub" >> /root/.cshrc

git config --global hub.protocol https
git config --global user.name 'lordzurp'
git config --global user.email 'zurp.online@gmail.com'

cd /
git init
git add /etc/rc.conf
git add /etc/sysctl.conf
git add /boot/loader.conf
git commit -m 'inital commit'

git create $git_backup
