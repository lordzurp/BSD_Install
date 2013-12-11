# Samba
pkg_add -r samba35 samba35-libsmbclient pam_smb

# installe les fichiers de config
cd /usr/local/etc
mv smb.conf smb.conf.dist
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/smb.conf
chmod 644 smb.conf

# configure le service dans /etc/rc.conf
echo '# Samba' >> /etc/rc.conf
echo 'samba_enable="YES"' >> /etc/rc.conf
echo '' >> /etc/rc.conf
read -p "pensez à ajouter les membres des groupes 1000 et 1001 dans samba via webmin :)"

# Configure le système
chmod 644 smb.conf
cd /etc
ln -s ../usr/local/etc/smb.conf
ln -s ..//usr/local/etc/samba
cd rc.d
ln -s ../../usr/local/etc/rc.d/samba

# installe le service dans avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/service.samba.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart
