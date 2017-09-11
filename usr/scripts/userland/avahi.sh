# Avahi
pkg_add -r avahi
cd /usr/local/etc/avahi
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi-daemon.conf

# installe les services  avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/service.ssh.service

# configure le service dans /etc/rc.conf
echo '# Avahi' >> /etc/rc.conf
echo 'avahi_daemon_enable="YES"' >> /etc/rc.conf
echo 'avahi_dnsconfd_enable="YES"' >> /etc/rc.conf
echo '' >> /etc/rc.conf
