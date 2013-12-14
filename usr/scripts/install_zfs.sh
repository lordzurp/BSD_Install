#!/bin/sh

echo " #############################################################################"
echo " #                                                                           #"
echo " # zbsd - Zurp BSD Installer                                                 #"
echo " #                                                                           #"
echo " # ce script doit etre edite AVANT de le lancer, pour configurer vos disques #"
echo " # sinon, votre disque sera efface et votre chat brulera votre maison        #"
echo " #                                                                           #"
echo " #############################################################################"
echo ""

fetch https://github.com/lordzurp/BSD_Install/raw/master/usr/scripts/bsd_flavour.conf
. bsd_flavour.conf

echo ""
echo " #############################################################################"
echo " #                                                                           #"
echo " # Editez le fichier bsd_flavour.conf pour l'adapter a votre configuration   #"
echo " #                                                                           #"
echo " #############################################################################"
echo ""
echo "la suite dans 10s ..."

sleep 10
echo ""
echo " c'est parti !"
echo ""



########################
# Debut de l'install
########################
if [ ${edit_script} != "OK" ];
then
    echo 'Fichier de config non personnalisé ! editez bsd_flavour.conf et relancez ce script'
    exit
fi


# on detruit le disque 
if [ ${erase_disc} = "YES" ];
	then
	
	echo ''
	echo '########################'
	echo "# Erase du disque"
	echo '########################'
	echo ''
	
	gpart delete -i 1 ${disque_1}
	gpart delete -i 2 ${disque_1}
	gpart delete -i 3 ${disque_1}
	gpart delete -i 4 ${disque_1}
	gpart delete -i 5 ${disque_1}
	gpart delete -i 6 ${disque_1}
	gpart delete -i 7 ${disque_1}
	gpart delete -i 8 ${disque_1}
	gpart delete -i 9 ${disque_1}
	gpart destroy -F ${disque_1}
	echo ''
	echo '########################'
	echo "# disque effacé"
	echo '########################'
	echo ''
	
fi

if [ ${partition_disc} = "YES" ];
	then
	echo ''
	echo '########################'
	echo "# Partition du disque"
	echo '########################'
	echo ''
	
	# création de la table GPT sur le disque 
	gpart create -s gpt ${disque_1}

	# création d une partition de boot, taille 512 secteurs
	gpart add -s 512 -t freebsd-boot ${disque_1}

	# création de la partition /, label system
	gpart add -s ${partition_systeme} -t freebsd-zfs -l system ${disque_1}

	# création de la partition /jail, label jail
	gpart add -s ${partition_jail} -t freebsd-zfs -l jail ${disque_1}

	# création de la partition /media, label data
	if [ ${partition_data} != "NO" ]; then
		gpart add -s ${partition_data} -t freebsd-zfs -l data ${disque_1}
	fi
	echo ''
	echo '########################'
	echo "# disque partitionné"
	echo '########################'
	echo ''
	gpart show
	
fi

if [ $create_pool = "YES" ];
	then

	echo ''
	echo '########################'
	echo "# Effacement du pool ZFS"
	echo '########################'
	echo ''
	
	
	# on nettoie le precedent pool
	zpool import -f -R /mnt ${sys_tank}
	zpool destroy -f ${sys_tank}

	zpool import -f -R /mnt ${jail_tank}
	zpool destroy -f ${jail_tank}

	zpool import -f -R /mnt ${data_tank}
	zpool destroy -f ${data_tank}
	
	echo ''
	echo '########################'
	echo "# pool destroyed"
	echo '########################'
	echo ''
	

	echo ''
	echo '########################'
	echo "# Creation du pool ZFS"
	echo '########################'
	echo ''
		
	# ça, c'etait dans le howto ... alors on laisse malgrè le warning ...
	mkdir /boot/zfs
	# on crée un dataset ZFS nommé ${sys_tank} sur la partition gpt/system
	zpool create -f -R /mnt -m / ${sys_tank} /dev/gpt/system
	zpool set feature@lz4_compress=enabled ${sys_tank}
	# on change le checksum
	zfs set checksum=fletcher4 ${sys_tank}
	# on active la deduplication
	zfs set dedup=on ${sys_tank}
	# on desactive la compression par défaut
	zfs set compression=lz4 ${sys_tank}
	zfs set atime=off ${sys_tank}

	# on export et réimporte le pool dans /mnt, en préservant zroot.cache dans /tmp
	zpool export ${sys_tank}
	zpool import -o cachefile=/tmp/zpool.cache -R /mnt ${sys_tank}

	# on crée l'arboréscence ZFS
	# on installe le système dans ${sys_tank}/root/current, ça permet de changer le /root si besoin (upgrade ...)
	zfs create                                 ${sys_tank}/root
	zfs create                                 ${sys_tank}/usr
	zfs create                                 ${sys_tank}/usr/local
	zfs create                 -o setuid=off   ${sys_tank}/usr/ports
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/usr/ports/distfiles
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/usr/ports/packages
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/usr/src
	zfs create                                 ${sys_tank}/var
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/var/crash
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/var/db
	zfs create -o exec=on      -o setuid=off   ${sys_tank}/var/db/pkg
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/var/empty
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/var/log
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/var/mail
	zfs create -o exec=off     -o setuid=off   ${sys_tank}/var/run
	zfs create -o exec=on      -o setuid=off   ${sys_tank}/var/tmp
	zfs create -o exec=on      -o setuid=off   ${sys_tank}/tmp

#	zfs create -o compression=on    -o exec=on      -o setuid=off	-o dedup=off   ${data_tank}


	# on définit l'emplacement de la racine pour le boot
	zpool set bootfs=${sys_tank}/root ${sys_tank}

	# /var/empty en lecture seule
	zfs set readonly=on ${sys_tank}/var/empty

	# /tmp en accès libre
	# inutile --> /tmp en ram (tmpmfs)
	# chmod 1777 /mnt/tmp
	chmod 1777 /mnt/var/tmp

	# jail_tank
	zpool create -f -R /mnt/jails -m /jails ${jail_tank} /dev/gpt/jail
	# on change le checksum
	zfs set checksum=fletcher4 ${jail_tank}
	zfs set dedup=on ${jail_tank}
	zfs set compression=lz4 ${jail_tank}
	zfs set atime=off ${jail_tank}
	
	# swap, sans dedup ni checksum
	zfs create -V ${partition_swap} ${sys_tank}/swap
	zfs set org.freebsd:swap=on ${sys_tank}/swap
	zfs set checksum=off ${sys_tank}/swap
	zfs set dedup=off ${sys_tank}/swap
	
	if [ ${partition_data} = "YES" ]; then
		zpool create -f -R /mnt/media -m /media ${data_tank} /dev/gpt/data
		# on change le checksum
		zfs set checksum=fletcher4 ${data_tank}
		# on desactive la deduplication
		zfs set dedup=off ${data_tank}
		# on desactive la compression par défaut
		zfs set compression=off ${data_tank}
		
	fi

	# on umount le tout et on refait les points de montage propres
	zfs umount -a
	zfs set mountpoint=none ${sys_tank}
	zfs set mountpoint=/ ${sys_tank}/root
	zfs set mountpoint=/usr ${sys_tank}/usr
	zfs set mountpoint=/var ${sys_tank}/var
	
	zfs set mountpoint=/jails ${jail_tank}
	zfs set mountpoint=/media ${data_tank}

	echo ''
	echo '########################'
	echo "# pool ready"
	echo '########################'
	echo ''
	zpool list
	zfs list
	

fi

# on export et importe le pool
zpool export ${sys_tank}
zpool import -o cachefile=/tmp/zpool.cache -R /mnt ${sys_tank}


# on y va ?
if [ ${valid_install} = "YES" ];
	then
	echo ''
	echo '########################'
	echo "# Debut de l'install"
	echo '########################'
	echo ''
	
	
	# Install de FreeBSD dans ${sys_tank}/root, monté sur /mnt
	mkdir /mnt/tmp/freebsd-dist
	cd /mnt/tmp/freebsd-dist
	fetch ${freebsd_install}/base.txz
	fetch ${freebsd_install}/lib32.txz
	fetch ${freebsd_install}/kernel.txz
	fetch ${freebsd_install}/doc.txz
#	on n'installe pas les ports --> switch vers Subversion
#	fetch ${freebsd_install}/ports.txz
#	fetch ${freebsd_install}/src.txz

	export DESTDIR=/mnt
	for file in base.txz lib32.txz kernel.txz doc.txz ports.txz src.txz;
	do (cat $file | tar --unlink -xpvJf - -C ${DESTDIR:-/}); done

	# on remet le cache zfs
	cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache
	
	# bootcode zfs
	gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptzfsboot -i 1 ${disque_1}

	# Installe fstab, rc.conf sysctl.conf, make.conf et loader.conf, après backup
	touch /mnt/etc/fstab

	########################
	### /root/.ssh/ma_cle_ssh.pub
	########################
	mkdir /mnt/root
	mkdir /mnt/root/.ssh
	echo ${ma_cle_ssh} > /mnt/root/.ssh/authorized_keys



	########################
	### /etc/rc.conf
	########################
	cd /mnt/etc/
	mv rc.conf rc.conf.dist
	fetch ${source_install}/etc/rc.conf

	########################
	### /etc/resolv.conf
	########################
	cd /mnt/etc/
	mv resolv.conf resolv.conf.dist
	fetch ${source_install}/etc/resolv.conf

	########################
	### /etc/sysctl.conf
	########################
	cd /mnt/etc/
	mv sysctl.conf sysctl.conf.dist
	fetch ${source_install}/etc/sysctl.conf

	########################
	### /boot/loader.conf
	########################
	cd /mnt/boot/
	mv loader.conf loader.conf.dist
	fetch ${source_install}/boot/loader.conf

	########################
	### /etc/ssh/sshd_config
	########################
	cd /mnt/etc/ssh/
	mv sshd_config sshd_config.dist
	fetch ${source_install}/etc/ssh/sshd_config

 
	 	############################
 # installation des scripts
	# installation de la config via svn
	 	############################
 mkdir /mnt/usr/scripts
 cd /mnt/usr/scripts
 fetch https://github.com/lordzurp/BSD_Install/raw/master/usr/scripts/bsd_flavour.conf
 fetch https://github.com/lordzurp/BSD_Install/raw/master/usr/scripts/post_install.sh
 chmod +x post_install.sh
 
 # version moderne
 # svn checkout $source_install_svn /mnt


fi


############################
# fin et reboot ?
############################
echo ''
echo '########################'
echo "# fin de install_zfs.sh"
echo '########################'
echo ''



if [ ${auto_reboot} = "YES" ];
then
	echo " 20sec avant reboot"
	sleep 20
	echo "time for reboot :)"
	shutdown -r now
else
	echo "rebootez maintenant :)"
	echo "et pensez à remettre votre Kimsufi en boot Hard Disk !!"
fi

