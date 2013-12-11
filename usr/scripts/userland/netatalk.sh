# installe netatalk via les ports
# veiller à ajouter l'option 'PAM' lors de la config
cd /usr/ports/net/netatalk && make install clean

# installe les fichiers de config
cd /usr/local/etc/
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/afpd.conf
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/netatalk.conf
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/AppleVolumes.default
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/AppleVolumes.timemachine
echo 'lagg0' >> /usr/local/etc/atalkd.conf

# configure le daemon dans /etc/rc.conf
echo '# Netatalk & AFP' >> /etc/rc.conf
echo 'netatalk_enable="YES"' >> /etc/rc.conf
echo 'afpd_enable="YES"' >> /etc/rc.conf
echo 'cnid_metad_enable="YES"' >> /etc/rc.conf
echo '' >> /etc/rc.conf

# Installe les services avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/backup.timemachine.service
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/service.netatalk.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart

