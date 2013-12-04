# VirtualBox
portinstall -c virtualbox-ose 
pw groupmod operator -m lordzurp

# installe phpvirtualbox
#pkg_add -r phpvirtualbox

# configure le système
echo "[system=10]" >> /etc/devfs.rules
echo "add path 'usb/*' mode 0660 group operator" >> /etc/devfs.rules

# configure le service dans /etc/rc.conf
echo '# VirtualBox' >> /etc/rc.conf
echo 'vboxservice_enable="YES"' >> /etc/rc.conf
echo 'vboxnet_enable="YES"' >> /etc/rc.conf
echo 'vboxheadless_enable="YES"' >> /etc/rc.conf
echo 'vboxheadless_user="root"' >> /etc/rc.conf
echo 'vboxheadless_machines="HomeBack"' >> /etc/rc.conf
echo 'vboxheadless_HomeBack_name="HomeBack"' >> /etc/rc.conf
echo 'vboxwebsrv_enable="YES"' >> /etc/rc.conf
echo '' >> /etc/rc.conf

# installe le service avahi
#cd /usr/local/etc/avahi/services
#fetch http://192.168.1.96/zurp_fs/usr_conf/avahi.services/web.phpvirtualbox.service

# redémarre avahi-daemon
#/usr/local/etc/rc.d/avahi-daemon restart
