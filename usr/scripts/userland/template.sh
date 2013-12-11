# Template File
pkg_add -r 

# installe les fichiers de config
cd /usr/local/etc
mv .conf .conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/template.conf

# Configure le système
cd /etc

# configure le service dans /etc/rc.conf
echo '# template' >> /etc/rc.conf
echo 'template_enable="YES"' >> /etc/rc.conf
echo '' >> /etc/rc.conf

# installe le service dans avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/service.template.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart

