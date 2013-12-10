#!/bin/sh

echo ""
echo "start post_install.sh "
echo "la suite dans 10s ..."
echo " "
sleep 10
echo " c'est parti !"

date -u > /root/start_time

. /usr/scripts/bsd_flavour.conf



if [ $tweak_system = "YES" ]; then
############################
### Système
############################
# Mail
cd /etc/mail
make aliases

# Time Zone
cd /etc/
ln -s $ma_time_zone localtime
fi


if [ $tweak_kernel = "YES" ]; then
############################
### Kernel
############################
#
# Insert Kernel tweak here
fi


if [ $tweak_security = "YES" ]; then
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


if [ $switch_subversion = "YES" ]; then
############################
### Ports - switch vers SubVersion
############################

# CVSUP deprecated !! use SubVersion instead !
rm -fr /usr/ports
rm -fr /var/db/sup/* /usr/sup
echo "fetch"
portsnap fetch
echo "extract"
portsnap extract
pkg_add -r subversion
cd /
rm -fr /var/db/portsnap/*
rm -fr /usr/ports
mkdir /usr/ports
svn checkout svn://svn.freebsd.org/ports/head /usr/ports
rm -fr /usr/src
mkdir /usr/src
svn checkout $svn_checkout /usr/src
chmod 700 /root/.subversion
fi


# tools
# cd /usr/ports/sysutils/logrotate/ && make install clean
# cd /usr/ports/editors/nano && make install clean
# cd /usr/ports/ports-mgmt/portmaster && make install clean BATCH=yes

if [ $tweak_users = "YES" ]; then
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


############################
### dummy_script auto-start
############################
# on lance l'update du kernel + world au reboot
echo '#!/bin/sh' > /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo '. /etc/rc.subr' >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo 'name="dummy"' >> /etc/rc.d/dummy_script
echo "start_cmd=\"\${name}_start\"" >> /etc/rc.d/dummy_script
echo "stop_cmd=\":\"" >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo 'dummy_start()' >> /etc/rc.d/dummy_script
echo '{' >> /etc/rc.d/dummy_script
echo '     rm -f /etc/rc.d/dummy_script' >> /etc/rc.d/dummy_script
echo '     date -u > /root/end_time' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     echo " post install terminee !"' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     uname -a' >> /etc/rc.d/dummy_script
echo '     echo " pensez a mettre a jour le monde et le kernel "' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     echo " start time : " && cat /root/start_time' >> /etc/rc.d/dummy_script
echo '     echo " end time   : " && cat /root/end_time' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '}' >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo "load_rc_config \"\$name\"" >> /etc/rc.d/dummy_script
echo "run_rc_command \"\$1\"" >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script

# on rend executable le dummy_script
chmod +x /etc/rc.d/dummy_script


############################
# reboot
############################
echo " "
echo " fin de post_install.sh"
echo " 10sec avant reboot"
echo " "


if [ $auto_reboot = "YES" ];
	then
	echo " 10sec avant reboot"
	sleep 10
	echo "time for reboot :)"
	shutdown -r now
fi

