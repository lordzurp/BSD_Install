#!/bin/sh

echo " #############################################################################"
echo " # ce script doit etre edite AVANT de le lancer, pour configurer vos disques #"
echo " # sinon, votre disque sera efface et votre chat brulera votre maison        #"
echo " #############################################################################"
echo ""
echo " Editez le fichier bsd_flavour.conf pour l'adapter a votre configuration"
echo ""

sleep 10
echo " c'est parti !"

fetch https://github.com/lordzurp/BSD_Install/raw/master/scripts/bsd_flavour.conf
. bsd_flavour.conf


########################
# Debut de l'install
########################
if [ $edit_script != "OK" ];
then
    echo 'Fichier de config non personnalisé ! editez bsd_flavour.conf et relancez ce script'
    exit
fi

date -u > /tmp/start_time

# on detruit le disque 
if [ $erase_disc = "YES" ];
	then
	
	echo "Erase du disque"
	
	gpart delete -i 1 $disque_1
	gpart delete -i 2 $disque_1
	gpart delete -i 3 $disque_1
	gpart delete -i 4 $disque_1
	gpart delete -i 5 $disque_1
	gpart destroy -F $disque_1
	echo "disque effacé"
fi

if [ $partition_disc = "YES" ];
	then
	echo "Partition du disque"
	
	# création de la table GPT sur le disque 
	gpart create -s gpt $disque_1
	# création d une partition de boot, taille 512 secteurs
	gpart add -s 512 -t freebsd-boot $disque_1
	# création de la partition système, début au secteur 2048 (4k ready), 20G, label system
	gpart add -b 2048 -s $partition_systeme -t freebsd-zfs -l system $disque_1
	if [ $partition_data = "YES" ]; then
		gpart add -t freebsd-zfs -l data $disque_1
	fi
	echo "disque partitionné"
fi

if [ $create_pool = "YES" ];
	then

	echo "Creation du pool ZFS"
	
	# on nettoie le precedent pool
	zpool import -f -R /mnt $sys_tank
	zpool destroy -f $sys_tank
	echo "pool destroyed"
	# ça, c'etait dans le howto ... alors on laisse
	mkdir /boot/zfs
	# on crée un dataset ZFS nommé $sys_tank sur la partition gpt/system
	zpool create -f -R /mnt -m / $sys_tank /dev/gpt/system
	# on change le checksum
	zfs set checksum=fletcher4 $sys_tank
	# on active la deduplication
	zfs set dedup=on $sys_tank
	# on desactive la compression par défaut
	zfs set compression=off $sys_tank

	# on export et réimporte le pool dans /mnt, en préservant zroot.cache dans /tmp
	zpool export $sys_tank
	zpool import -o cachefile=/tmp/zpool.cache -R /mnt $sys_tank

	# on crée l'arboréscence ZFS
	# on installe le système dans $sys_tank/root, ça permet de changer le /root si besoin (upgrade ...)
	zfs create                                                      $sys_tank/root
	zfs create                                                      $sys_tank/usr
	zfs create                                                      $sys_tank/usr/local
	zfs create -o compression=lzjb                  -o setuid=off   $sys_tank/usr/ports
	zfs create -o compression=off   -o exec=off     -o setuid=off   $sys_tank/usr/ports/distfiles
	zfs create -o compression=off   -o exec=off     -o setuid=off   $sys_tank/usr/ports/packages
	zfs create -o compression=lzjb  -o exec=off     -o setuid=off   $sys_tank/usr/src
	zfs create -o compression=on                    -o setuid=off   $sys_tank/usr/jails
	zfs create                                                      $sys_tank/var
	zfs create -o compression=lzjb  -o exec=off     -o setuid=off   $sys_tank/var/crash
	zfs create                      -o exec=off     -o setuid=off   $sys_tank/var/db
	zfs create -o compression=lzjb  -o exec=on      -o setuid=off   $sys_tank/var/db/pkg
	zfs create                      -o exec=off     -o setuid=off   $sys_tank/var/empty
	zfs create -o compression=lzjb  -o exec=off     -o setuid=off   $sys_tank/var/log
	zfs create -o compression=gzip  -o exec=off     -o setuid=off   $sys_tank/var/mail
	zfs create                      -o exec=off     -o setuid=off   $sys_tank/var/run
	zfs create -o compression=lzjb  -o exec=on      -o setuid=off   $sys_tank/var/tmp
	zfs create -o compression=on    -o exec=on      -o setuid=off   $sys_tank/tmp

#	zfs create -o compression=on    -o exec=on      -o setuid=off	-o dedup=off   $data_tank


	# on définit l'emplacement de la racine pour le boot
	zpool set bootfs=$sys_tank/root $sys_tank

	# /var/empty en lecture seule
	zfs set readonly=on $sys_tank/var/empty

	# /tmp en accès libre
	chmod 1777 /mnt/tmp
	chmod 1777 /mnt/var/tmp

	# swap, sans dedup ni checksum
	zfs create -V $partition_swap $sys_tank/swap
	zfs set org.freebsd:swap=on $sys_tank/swap
	zfs set checksum=off $sys_tank/swap
	zfs set dedup=off $sys_tank/swap
	
	if [ $partition_data = "YES" ]; then
		zpool create -f -R /mnt/home -m /home $data_tank /dev/gpt/data
		# on change le checksum
		zfs set checksum=fletcher4 $data_tank
		# on desactive la deduplication
		zfs set dedup=off $data_tank
		# on desactive la compression par défaut
		zfs set compression=off $data_tank
		
	fi

	# on umount le tout et on refait les points de montage propres
	zfs umount -a
	zfs set mountpoint=none $sys_tank
	zfs set mountpoint=/ $sys_tank/root
	zfs set mountpoint=/tmp $sys_tank/tmp
	zfs set mountpoint=/home $data_tank
	zfs set mountpoint=/usr $sys_tank/usr
	zfs set mountpoint=/var $sys_tank/var

	echo "pool ready"

fi

# on export et importe le pool
zpool export $sys_tank
zpool import -o cachefile=/tmp/zpool.cache -R /mnt $sys_tank


# on y va ?
if [ $valid_install = "YES" ];
	then
	echo "Debut de l'install"
	
	# Install de FreeBSD dans $sys_tank/root, monté sur /mnt
	mkdir /mnt/tmp/freebsd-dist
	cd /mnt/tmp/freebsd-dist
	fetch $freebsd_install/base.txz
	fetch $freebsd_install/lib32.txz
	fetch $freebsd_install/kernel.txz
	fetch $freebsd_install/doc.txz
	fetch $freebsd_install/ports.txz
	fetch $freebsd_install/src.txz

	export DESTDIR=/mnt
	for file in base.txz lib32.txz kernel.txz doc.txz ports.txz src.txz;
	do (cat $file | tar --unlink -xpvJf - -C ${DESTDIR:-/}); done

	# on remet le cache zfs
	cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache
	
	# bootcode zfs
	gpart bootcode -b /mnt/boot/pmbr -p /mnt/boot/gptzfsboot -i 1 $disque_1

	# Installe fstab, rc.conf sysctl.conf, make.conf et loader.conf, après backup
	cp /tmp/start_time /mnt/root/start_time
	touch /mnt/etc/fstab


	########################
	### /root/.ssh/ma_cle_ssh.pub
	########################
	mkdir /mnt/root
	mkdir /mnt/root/.ssh
	echo $ma_cle_ssh > /mnt/root/.ssh/authorized_keys
	
	########################
	### /etc/rc.conf
	########################
	cd /mnt/etc/
	mv rc.conf rc.conf.dist
	fetch $source_install/root/etc/rc.conf


	########################
	### /etc/sysctl.conf
	########################
	cd /mnt/etc/
	mv sysctl.conf sysctl.conf.dist
	fetch $source_install/root/etc/sysctl.conf


	########################
	### /boot/loader.conf
	########################
	cd /mnt/boot/
	mv loader.conf loader.conf.dist
	fetch $source_install/root/boot/loader.conf


	########################
	### /etc/ssh/sshd_config
	########################
	cd /mnt/etc/ssh/
	mv sshd_config sshd_config.dist
	fetch $source_install/root/etc/ssh/sshd_config


	############################
	# Install du script post_install
	############################
	mkdir /mnt/usr/scripts
	mkdir /mnt/usr/scripts/userland
	cd /mnt/usr/scripts
	fetch $source_install/scripts/update_scripts.sh
	fetch $source_install/scripts/bsd_flavour.conf
	chmod +x update_scripts.sh


	############################
	### dummy_script auto-start
	############################
	# au reboot, on met à jour les scripts et on lance le post_install
	echo '#!/bin/sh' > /mnt/etc/rc.d/dummy_script
	echo '' >> /mnt/etc/rc.d/dummy_script
	echo '. /etc/rc.subr' >> /mnt/etc/rc.d/dummy_script
	echo '' >> /mnt/etc/rc.d/dummy_script
	echo 'name="dummy"' >> /mnt/etc/rc.d/dummy_script
	echo "start_cmd=\"\${name}_start\"" >> /mnt/etc/rc.d/dummy_script
	echo "stop_cmd=\":\"" >> /mnt/etc/rc.d/dummy_script
	echo '' >> /mnt/etc/rc.d/dummy_script
	echo 'dummy_start()' >> /mnt/etc/rc.d/dummy_script
	echo '{' >> /mnt/etc/rc.d/dummy_script
	echo '     rm -f /etc/rc.d/dummy_script' >> /mnt/etc/rc.d/dummy_script
	echo '     /usr/scripts/update_scripts.sh' >> /mnt/etc/rc.d/dummy_script
	echo '     echo " "' >> /mnt/etc/rc.d/dummy_script
	echo '     echo "install termine, lancer /usr/scripts/post_install.sh"' >> /mnt/etc/rc.d/dummy_script
	#echo '     /usr/scripts/post_install.sh' >> /mnt/etc/rc.d/dummy_script
	echo '     echo " "' >> /mnt/etc/rc.d/dummy_script
	echo '}' >> /mnt/etc/rc.d/dummy_script
	echo '' >> /mnt/etc/rc.d/dummy_script
	echo "load_rc_config \"\$name\"" >> /mnt/etc/rc.d/dummy_script
	echo "run_rc_command \"\$1\"" >> /mnt/etc/rc.d/dummy_script
	echo '' >> /mnt/etc/rc.d/dummy_script

	# on rend executable le dummy_script
	chmod +x /mnt/etc/rc.d/dummy_script

fi


############################
# fin et reboot ?
############################
echo " "
echo " fin de install_zfs.sh"
echo "pensez à changer votre passwd root avant de redemarrer !"
echo " "

date -u > /mnt/root/fin_install_time

if [ $auto_reboot = "YES" ];
	then
	echo " 20sec avant reboot"
	sleep 20
	echo "time for reboot :)"
	shutdown -r now
fi

