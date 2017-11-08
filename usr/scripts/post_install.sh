#!/bin/sh

echo ""
echo "start post_install.sh "
echo "la suite dans 10s ..."
echo " "
sleep 10
echo " c'est parti !"


############################
# Journal de bord du capitaine
# 11 septembre 1973
############################

echo " " >> /usr/scripts/journal.log
echo " ############################ " >> /usr/scripts/journal.log
echo " " >> /usr/scripts/journal.log
echo " # post_install.sh" >> /usr/scripts/journal.log
date -u >> /usr/scripts/journal.log
echo " debut " >> /usr/scripts/journal.log
echo " " >> /usr/scripts/journal.log

. /usr/scripts/bsd_flavour.conf



#cd $scripts
cd /usr/scripts

#svnlite checkout https://github.com/lordzurp/BSD_Install/trunk/usr/scripts .
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
	
	#zpool import ${jail_tank}
	#zpool import ${data_tank}
	
	zpool import media_tank
	zpool import data_tank
	zpool import jail_tank
	
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


if [ ${tweak_kernel} = "YES" ]; then
	############################
	### Kernel
	############################
	#
	# Insert Kernel tweak here
	
	cd /usr/src/sys/modules
	for module in mlx4 mlxen; do
	cd $module
		make
		make install
		sync
		kldload $module || true
		printf "${module}_load=\"YES\"\n" >> /boot/loader.conf
		cd ..
	done
	kldstat
	
	dhclient mlxen0
	
fi


if [ ${system_install} = "YES" ]; then
	#
	# Attention !!
	#
	# cette partie ne fonctionne pas en unatented !
	# a utiliser uniquement depuis une console

	# init pkg et install des ports
	env ASSUME_ALWAYS_YES=YES pkg bootstrap
	portsnap fetch
	portsnap extract
	
	# màj des sources
	pkg install -y ca_root_nss #subversion
	rm -rf /usr/src
	svnlite checkout ${freebsd_svn_checkout}/${freebsd_current_release} /usr/src
	
	
	echo "CPUTYPE?=${cputype}" >> /etc/make.conf
	ln -s /usr/scripts/misc/skylake.kernel /usr/src/sys/amd64/conf/skylake

	#chmod 700 /root/.subversion

	############################
	### Ports utiles
	############################

	pkg install -y logrotate nano portmaster gzip sudo clean tmux htop bash zip unzip smartmontools ipmitool avahi nut iperf
	ln -s /usr/local/bin/bash
	echo '/bin/bash' >> /etc/shells

	# Gestion de l'alimentation
	pkg install -y intel-pcm stress i7z 
	
	# Monitoring
	pkg install -y monitorix
	mv /usr/local/etc/monitorix.conf /usr/local/etc/monitorix.conf.dist
	cp /usr/local/etc/monitorix.conf.zurp /usr/local/etc/monitorix.conf
	sysrc monitorix_enable="YES"

	# CBSD and tools
	pkg install -y cbsd git grub2-bhyve
	#pkg install nginx php71 php71-zip php71-sqlite3 php71-session php71-pdo_sqlite php71-opcache php71-json devel/git sysutils/py-supervisor security/ca_root_nss www/node www/npm shells/bash lang/python27 security/gnutls net/libvncserver 
	
	#zpool import jail_tank
	
	env workdir="/usr/cbsd" /usr/local/cbsd/sudoexec/initenv
	
	sysrc cbsdd_enable="YES"
	
	service cbsdd start
	
	/usr/local/bin/cbsd srcup
	/usr/local/bin/cbsd buildworld maxjobs=4
	/usr/local/bin/cbsd installworld
	
	
	# Sharing tools
	#pkg install -y samba46
	
	#sysrc samba_server_enable="YES"
	
	
	

	# debootstrap ezjail tmux pstree 

	# on installe gnome, parce qu'un bureau, parfois c'est cool
	#pkg install -y xorg gnome3-lite firefox gedit 
	#echo 'exec gnome-session' >> ~/.xsession

	# VirtualBox, parce qu'il le vaut bien !
	#pkg install -y virtualbox-ose virtualbox-ose-additions


	# Jails
	# Le gros morceau ...


	# Fin install system
fi


if [ ${tweak_users} = "YES" ]; then
	############################
	### Gestion des Users
	############################
	# on ajoute les users/group du système
	pw groupadd -q -n humans -g 1000
	pw groupadd -q -n public_user -g 1010

	# Utilisateurs

	# John Doe
	echo -n 'johndoe' |	pw useradd -n johndoe -u 1000 -g humans -d /home/media -s /usr/sbin/nologin -h 0
	# LordZurp
	echo -n 'lordzurp' | pw useradd -n lordzurp -u 1001 -g humans -d /home/lordzurp -G wheel -s /bin/csh -m -h 0
	# Aurel
	echo -n 'aurel' |	pw useradd -n aurel -u 1002 -g humans -d /home/aurel -s /usr/sbin/nologin -h 0
	# Public
	pw useradd -n public -u 1050 -g public_user -d /home/public -s /usr/sbin/nologin -m
	# Media
	pw useradd -n media -u 1051 -g public_user -s /usr/sbin/nologin -m

	############################
	### tweak du .cshrc root
	############################
	#svnlite checkout $source_install_svn/root /root
	cp /root/cshrc /root/.cshrc

	############################
	### tweak du .cshrc lordzurp
	############################
	cp /root/cshrc /home/lordzurp/.cshrc
fi



# on crée un snapshot ZFS du système tel qu'à l'origine
zfs snapshot -r ${sys_tank}/root/initial@fresh_install


############################
# reboot
############################
echo " "
echo " fin de post_install.sh"
echo " "

echo " " >> /usr/scripts/journal.log
date -u >> /usr/scripts/journal.log
echo " fin " >> /usr/scripts/journal.log
echo " " >> /usr/scripts/journal.log

if [ ${auto_reboot} = "YES" ]; then
	echo " 10sec avant reboot"
	sleep 10
	echo "time for reboot :)"
	shutdown -r now
	else
	echo "rebootez maintenant !"
fi
