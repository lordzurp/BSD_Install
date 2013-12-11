#!/bin/sh

echo ""
echo "start update_kernel.sh "
echo "la suite dans 10s ..."
echo " "
sleep 10
echo " c'est parti !"


date -u > /root/start_time

############################
# Backup, Clean & Update
############################
rm -rf /boot/kernel.last ; cp -Rp /boot/kernel /boot/kernel.last
chflags -R noschg /usr/obj/*
rm -rf /usr/obj/*

# Mergemaster Pre-buildworld mode
mergemaster -p

# Récuperer les sources à jour 
svn checkout svn://svn.freebsd.org/base/releng/9.1 /usr/src

cd /usr/src/
# Compile le nouveau monde
time -h -o /root/time_buildworld make buildworld -j5 -s
# Compile le nouveau noyau
time -h -o /root/time_buildkernel make buildkernel -j5 -s
# Installe le nouveau noyau
make -s installkernel

########################
### dummy script auto-start
########################
# on lance la suite au reboot
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
echo '     /usr/scripts/update_world.sh' >> /etc/rc.d/dummy_script
echo '}' >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo "load_rc_config \"\$name\"" >> /etc/rc.d/dummy_script
echo "run_rc_command \"\$1\"" >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script

# on rend executable le dummy_script
chmod +x /etc/rc.d/dummy_script

# on force en single user et on bloque les Jails
sed -i '' -e 's/kern.securelevel=/#kern.securelevel/g' /etc/rc.conf
sed -i '' -e 's/ezjail_enable="YES"/ezjail_enable="NO"/g' /etc/rc.conf

############################
# reboot
############################
echo " "
echo " fin de post_install.sh"
echo " 10sec avant reboot"
echo " "
sleep 10
echo "time for reboot :)"
shutdown -r now