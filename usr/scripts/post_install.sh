#!/bin/sh

echo ""
echo "start post_install.sh "
echo "la suite dans 10s ..."
echo " "
sleep 10
echo " c'est parti !"


. /usr/scripts/bsd_flavour.conf

#cd $scripts
cd /usr/scripts

svn checkout $source_install_svn/usr/scripts .
chmod -R +x *

if [ ${tweak_system} = "YES" ]; then
############################
### Système
############################
# Mail
cd /etc/mail
make aliases

# Time Zone
cd /etc/
ln -s ${ma_time_zone} localtime

echo "" > /etc/motd
echo " Welcome back, Sir !" >> /etc/motd
echo "" >> /etc/motd


zpool import ${jail_tank}
zpool import ${data_tank}
fi


if [ ${tweak_kernel} = "YES" ]; then
############################
### Kernel
############################
#
# Insert Kernel tweak here
fi


if [ ${tweak_security} = "YES" ]; then
############################
### Security Tweaks
############################
# http://forums.freebsd.org/showthread.php?t=4108
# http://www.bsdguides.org/guides/freebsd/security/harden.php

chmod 640 /var/log/messages

# blowfish for password hash
echo "crypt_default=blf" >> /etc/auth.conf
sed -i '' s/md5/blf/ /etc/login.conf
# on recrée la base des logins
cap_mkdb /etc/login.conf

# set root password
# passwd root
fi


if [ ${system_install} = "YES" ]; then
	
#
# Attention !!
#
# cette partie ne fonctionne pas en unatented !
# a utiliser uniquement depuis une console


# switch to PKG
env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg

# màj de la db packages pour PKG
echo 'WITH_PKGNG="YES"' >> /etc/make.conf
echo 'WITH_SVN="YES' >> /etc/make.conf

mkdir /etc/pkg
cat << EOF36 > /etc/pkg/FreeBSD.conf
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/\${ABI}/latest",
  mirror_type: "srv",
  enabled: yes
}
EOF36

mv /usr/local/etc/pkg.conf /usr/local/etc/pkg.conf.old
/usr/local/sbin/pkg2ng

/usr/local/sbin/pkg update

cd /
rm -fr /var/db/portsnap/*

# on supprime /usr/ports et on recrée tout de suite le chemin
zfs destroy -r ${sys_tank}/usr/ports
zfs create                 -o setuid=off   ${sys_tank}/usr/ports
zfs create -o exec=off     -o setuid=off   ${sys_tank}/usr/ports/distfiles
zfs create -o exec=off     -o setuid=off   ${sys_tank}/usr/ports/packages

echo '# on met a jour les ports avec svn'
echo '# attention, ça va etre long ...'
echo '# bon, là on va pas le faire vraiment :)'
# svn checkout svn://svn.freebsd.org/ports/head /usr/ports

# on supprime /usr/src et on recrée tout de suite le chemin
zfs destroy ${sys_tank}/usr/src
zfs create -o exec=off     -o setuid=off   ${sys_tank}/usr/src


echo '# on met a jour les sources avec svn'
echo '# attention, ça va etre long ...'
echo '# bon, là on va pas le faire vraiment :)'
# svn checkout $svn_checkout /usr/src

chmod 700 /root/.subversion

############################
### Ports utiles
############################
/usr/local/sbin/pkg install logrotate
/usr/local/sbin/pkg install nano
/usr/local/sbin/pkg install portmaster

# Jails
# Le gros morceau ...

/usr/local/sbin/pkg install ezjail


# Fin install system
fi


if [ ${tweak_users} = "YES" ]; then
############################
### Gestion des Users
############################
# on ajoute les users/group du système
pw groupadd -q -n user -g 1000
pw groupadd -q -n public_user -g 1010

# Utilisateurs
#echo -n 'toto' |\
#passwd
# LordZurp
echo -n 'lordzurp' | pw adduser -n lordzurp -u 1000 -g user -G wheel -s /bin/csh -m -h 0
# John Doe
echo -n 'johndoe' |\
pw adduser -n johndoe -u 1040 -g user -d /dev/null -s /bin/sh -h 0
# Public
pw adduser -n public -u 1050 -g public_user -s /usr/sbin/nologin -m
# Media
pw adduser -n media -u 1051 -g public_user -s /usr/sbin/nologin -m


############################
### tweak du .cshrc root
############################
cat << EOF33 > /root/.cshrc
# $FreeBSD: release/9.0.0/etc/root/dot.cshrc 170088 2007-05-29 06:37:58Z dougb $
#
# .cshrc - csh resource script, read at beginning of execution by each shell
#
# see also csh(1), environ(7).
#

alias h		history 25
alias j		jobs -l
alias ls	ls -G
alias la	ls -a
alias lf	ls -FA
alias ll	ls -lA
alias svn_maj_ports		svn checkout svn://svn.freebsd.org/ports/head /usr/ports

# A righteous umask
umask 22

set path = (/sbin /bin /usr/sbin /usr/bin /usr/games /usr/local/sbin /usr/local/bin \$HOME/bin)

setenv	EDITOR	nano
setenv	PAGER	more
setenv	BLOCKSIZE	K

if (\$?prompt) then
	# An interactive shell -- set some stuff up
	set prompt = "%P %{\e[31m%}%n%{\e[0m%}@%{\e[32m%}%M%{\e[0m%} \n%~/ "
	set filec
	set history = 1000
	set savehist = 1000
	set mail = (/var/mail/\$USER)
	if ( \$?tcsh ) then
		bindkey "^W" backward-delete-word
		bindkey -k up history-search-backward
		bindkey -k down history-search-forward
	endif
endif


EOF33


############################
### tweak du .cshrc lordzurp
############################
cat << EOF24 > /home/lordzurp/.cshrc
# $FreeBSD: release/9.0.0/etc/root/dot.cshrc 170088 2007-05-29 06:37:58Z dougb $
#
# .cshrc - csh resource script, read at beginning of execution by each shell
#
# see also csh(1), environ(7).
#

alias h		history 25
alias j		jobs -l
alias ls	ls -G
alias la	ls -a
alias lf	ls -FA
alias ll	ls -lA

# A righteous umask
umask 22

set path = (/sbin /bin /usr/sbin /usr/bin /usr/games /usr/local/sbin /usr/local/bin \$HOME/bin)

setenv	EDITOR	nano
setenv	PAGER	more
setenv	BLOCKSIZE	K

if (\$?prompt) then
	# An interactive shell -- set some stuff up
	set prompt = "%P %{\e[32m%}%n%{\e[0m%}@%{\e[32m%}%M%{\e[0m%} \n%~/ "
	set filec
	set history = 1000
	set savehist = 1000
	set mail = (/var/mail/\$USER)
	if ( \$?tcsh ) then
		bindkey "^W" backward-delete-word
		bindkey -k up history-search-backward
		bindkey -k down history-search-forward
	endif
endif


EOF24
fi



# on crée un snapshot ZFS du système tel qu'à l'origine
zfs snapshot -r ${sys_tank}/root@fresh_install


############################
# reboot
############################
echo " "
echo " fin de post_install.sh"
echo " "


if [ ${auto_reboot} = "YES" ];
	then
	echo " 10sec avant reboot"
	sleep 10
	echo "time for reboot :)"
	shutdown -r now
else
	echo "rebootez maintenant !"
fi

