# VirtualBox
pkg_add -r virtualbox-ose
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
echo 'vboxheadless_machines="HomeBack"' >> /etc/rc.conf
echo 'vboxheadless_HomeBack_name="HomeBack"' >> /etc/rc.conf
#echo 'vboxguest_enable="YES"' >> /etc/rc.conf
#echo 'vboxwebsrv_enable="YES"' >> /etc/rc.conf
#echo 'devfs_system_ruleset="system"' >> /etc/rc.conf
echo '' >> /etc/rc.conf

# installe le service avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/web.phpvirtualbox.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart