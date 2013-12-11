# Webmin
echo 'install webmin '
# configure le service dans /etc/rc.conf
echo '# Webmin' >> /etc/rc.conf
cd /usr/local 
fetch http://prdownloads.sourceforge.net/webadmin/webmin-1.550.tar.gz 
gunzip webmin-1.550.tar.gz 
tar -xvf webmin-1.550.tar 
cd webmin-1.550 
./setup.sh
echo '' >> /etc/rc.conf

# installe le service dans avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/web.webmin.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart

