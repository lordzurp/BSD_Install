# Webmin
echo 'install webmin '
# configure le service dans /etc/rc.conf
echo '# Webmin' >> /etc/rc.conf
cd /usr/local 
fetch http://www.webmin.com/download/webmin-current.tar.gz 
gunzip webmin-current.tar.gz 
tar -xvf webmin-current.tar 
cd webmin-1580 
./setup.sh
echo '' >> /etc/rc.conf

# installe le service dans avahi
cd /usr/local/etc/avahi/services
fetch http://chez.tinico.free.fr/zurp_fs/usr_conf/avahi.services/web.webmin.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart

