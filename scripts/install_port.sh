#!/bin/sh

#passwd
#cd /etc/mail ; make aliases

#freebsd-update fetch upgrade
#freebsd-update install

#portsnap fetch update
#portsnap extract
#portsnap update

# make world
#cd /usr/src/
#make buildworld

#mergemaster -p
#make installworld
#mergemaster -i

# make kernel zurpatator2
# cd /sys_tank/usr/src/sys/amd64/conf/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/zurpatator2
# cd /usr/src/ ; make buildkernel KERNCONF=zurpatator2
# cd /usr/src/ ; make installkernel KERNCONF=zurpatator2

cd /usr/ports/devel/libtool ; make install clean
cd /usr/ports/databases/db41 ; make install clean
cd /usr/ports/converters/libiconv ; make install clean
cd /usr/ports/devel/gettext ; make install clean
cd /usr/ports/devel/autoconf-wrapper ; make install clean
cd /usr/ports/devel/gmake ; make install clean
# Ports manager
cd /usr/ports/ports-mgmt/portupgrade ; make config-recursive ; make fetch-recursive ; make install clean
# managepkg portmaster

portupgrade -N lang/gcc46

# fetch all
# portupgrade -N -c -F php5 php5-bsdconv php5-bz2 php5-ctype php5-filter php5-gd php5-iconv php5-mbstring php5-mcrypt php5-mysql php5-openssl php5-session php5-xml php5-zip php5-zlib p5-Authen-Libwrap p5-IO-Tty p5-libwww p5-Net-OpenSSH p5-Net-SSH2 p5-Net-SSLeay p5-perl-ldap p5-String-Multibyte p5-Mail-SpamAssassin krb5 bind96 xorg xorg-drivers liberation-fonts-ttf xfe xfce samba35 samba35-libsmbclient pam_smb mysql-client mysql-server mysql-scripts lighttpd webmin usermin phpvirtualbox phpmyadmin webalizer bash aircrack-ng virtualbox-ose virtualbox-ose-additions iperf firefox firefox-i18n chromium bsdconv openssl openldap-client nss ca_root_nss nss_mdns gzip  fetchmail procmail   libnss-mysql pam_mysql clean gnupg logrotate proftpd proftpd-mysql screen smartmontools      

# install all
# portupgrade -N gcc php5 perl python ruby php5-bsdconv php5-bz2 php5-ctype php5-filter php5-gd php5-iconv php5-mbstring php5-mcrypt php5-mysql php5-openssl php5-session php5-xml php5-zip php5-zlib p5-Authen-Libwrap p5-IO-Tty p5-libwww p5-Net-OpenSSH p5-Net-SSH2 p5-Net-SSLeay p5-perl-ldap p5-String-Multibyte p5-Mail-SpamAssassin krb5 bind96 xorg xorg-drivers liberation-fonts-ttf xfe xfce samba35 samba35-libsmbclient pam_smb mysql-client mysql-server mysql-scripts apache lighttpd webmin usermin phpvirtualbox phpmyadmin webalizer bash aircrack-ng virtualbox-ose virtualbox-ose-additions iperf firefox firefox-i18n chromium bsdconv openssl openldap-client nss ca_root_nss nss_mdns gzip  fetchmail procmail   libnss-mysql pam_mysql clean gnupg logrotate proftpd proftpd-mysql screen smartmontools      

# java

# post install scripts
#cd /sys_tank/usr/local/etc/hal/fdi/policy/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/x11-input.fdi
#Xorg -configure
#mv xorg.conf.new /etc/X11/xorg.conf
#/usr/local/lib/webmin/setup.sh
