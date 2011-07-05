# Transmission
pkg_add -r transmission

# installe les fichiers de config
cd /usr/local/etc/transmission/home
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/settings.json

# Configure le système
mkdir '/home/media/#5_Download/#1_BitTorrent'
wget -NP /usr/local/etc/transmission/home/blocklists http://update.transmissionbt.com/level1.gz


# configure le service dans /etc/rc.conf
echo '# transmission' >> /etc/rc.conf
echo 'transmission_enable="YES"' >> /etc/rc.conf
echo 'transmission_user="transmission"' >> /etc/rc.conf
echo 'transmission_conf_dir="/usr/local/etc/transmission/home"' >> /etc/rc.conf
echo 'transmission_download_dir="/home/media/#5_Download/#1_BitTorrent"' >> /etc/rc.conf
echo '' >> /etc/rc.conf

# installe le service dans avahi
cd /usr/local/etc/avahi/services
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/web.transmission.service

# redémarre avahi-daemon
/usr/local/etc/rc.d/avahi-daemon restart

# source
# http://pynej.blogspot.com/2010/02/set-up-transmission-deamon-bittorrent.html