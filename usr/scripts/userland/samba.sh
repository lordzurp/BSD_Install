# Samba
pkg install samba46 

# installe les fichiers de config
cd /usr/local/etc
mv smb4.conf smb4.conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr/local/etc/smb4.conf.zurp smb4.conf
chmod 644 smb.conf

# configure le service dans /etc/rc.conf
sysrc samba_server_enable="YES"

read -p "pensez à ajouter les membres des groupes 1000 et 1001 dans samba via webmin :)"

# Configure le système
chmod 644 smb4.conf
cd /etc
ln -s ../usr/local/etc/smb4.conf
ln -s ../usr/local/etc/samba
cd rc.d
ln -s ../../usr/local/etc/rc.d/samba

# installe le service dans avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr/local/misc/avahi.services/service.samba.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart

