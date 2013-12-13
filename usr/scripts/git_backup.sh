#!/bin/sh

# Install git, obviously
pkg install git
pkg install hub

#gen ssh keys to git login
cd ~/.ssh
ssh-keygen -t rsa -C "zurp.online@gmail.com" -P '' -f "git_ssh"
ssh-add git_ssh
cat git_ssh.pub



# alias hub to git to enlarge your superpower
echo "alias git hub" >> /root/.cshrc

git config --global hub.protocol ssh
git config --global user.name 'lordzurp'
git config --global user.email 'zurp.online@gmail.com'

cd /
git init
git add /etc/rc.conf
git add /etc/sysctl.conf
git add /boot/loader.conf
git commit -m 'inital commit'

git create $git_backup
git push origin master

# ajout des fichiers à suivre
watched_files="
/etc/rc.conf
/etc/fstab
/etc/resolv.conf
/etc/sysctl.conf
/boot/loader.conf
"
for I in ${watched_files}; do
	svnlite add ${I}
done


