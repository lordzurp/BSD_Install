#!/bin/sh

echo ""
echo "start update_world.sh"
echo "la suite dans 10s ..."
echo " "
sleep 10
echo " c'est parti !"


############################
# Journal de bord du capitaine
# 27 fevrier 1637
############################

echo " " >> /usr/scripts/journal.log
echo " # update_world.sh" >> /usr/scripts/journal.log
echo " " >> /usr/scripts/journal.log
echo " debut " >> /usr/scripts/journal.log
date -u >> /usr/scripts/journal.log
echo " " >> /usr/scripts/journal.log

############################
# installworld
############################
cd /usr/src
make -s installworld
make -s delete-old
make delete-old-libs
# mergemaster -U -i
#make delete-old-libs


# retype root passwd
# passwd


########################
### dummy_script auto-start
########################
# on termine l'install du new world et on affiche les metrics
echo '#!/bin/sh' > /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo '. /etc/rc.subr' >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo 'name="dummy"' >> /etc/rc.d/dummy_script
echo 'start_cmd="${name}_start"' >> /etc/rc.d/dummy_script
echo 'stop_cmd=":"' >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo 'dummy_start()' >> /etc/rc.d/dummy_script
echo '{' >> /etc/rc.d/dummy_script
echo '     rm -f /etc/rc.d/dummy_script' >> /etc/rc.d/dummy_script
echo "     sed -i \'\' -e \'s/#kern.securelevel=/kern.securelevel/g\' /etc/rc.conf\'" >> /etc/rc.d/dummy_script
echo "     sed -i \'\' -e \'s/ezjail_enable=\"NO\"/ezjail_enable=\"YES\"/g\' /etc/rc.conf\'" >> /etc/rc.d/dummy_script
echo '     cd /usr/src && make delete-old-libs' >> /etc/rc.d/dummy_script
echo '     date -u > /root/end_build_time' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     echo " Update done ! "' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     uname -a' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     echo " start time : " && cat /root/start_build_time' >> /etc/rc.d/dummy_script
echo '     echo " end time   : " && cat /root/end_build_time' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '     echo " time to build kernel : " && cat /root/time_buildkernel' >> /etc/rc.d/dummy_script
echo '     echo " time to build world : " && cat /root/time_buildworld' >> /etc/rc.d/dummy_script
echo '     echo " "' >> /etc/rc.d/dummy_script
echo '}' >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script
echo 'load_rc_config $name' >> /etc/rc.d/dummy_script
echo 'run_rc_command "$1"' >> /etc/rc.d/dummy_script
echo '' >> /etc/rc.d/dummy_script

# on rend executable le dummy_script
chmod +x /etc/rc.d/dummy_script


############################
# fin & reboot
############################

echo " fin " >> /usr/scripts/journal.log
date -u >> /usr/scripts/journal.log
echo " " >> /usr/scripts/journal.log

if [ ${auto_reboot} = "YES" ];
then
	echo " 20sec avant reboot"
	sleep 20
	echo "time for reboot :)"
	shutdown -r now
else
	echo "rebootez maintenant :)"
fi

