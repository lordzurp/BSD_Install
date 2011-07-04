#!/bin/sh


############
### Ports ###
############

#cd /usr/ports/devel/libtool ; make install clean
#cd /usr/ports/databases/db41 ; make install clean
#cd /usr/ports/converters/libiconv ; make install clean
#cd /usr/ports/devel/gettext ; make install clean
#cd /usr/ports/devel/autoconf-wrapper ; make install clean
#cd /usr/ports/devel/gmake ; make install clean
# Ports manager
#cd /usr/ports/ports-mgmt/portupgrade ; make config-recursive ; make fetch-recursive ; make install clean
# managepkg portmaster

#portupgrade -N lang/gcc46

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


############
### Packages ###
############


# C Tools & autres utils
#pkg_add -r bsdconv libtool db41 libiconv gettext autoconf-wrapper  pcre libsigc++ libcheck eject hal



############
### Web ###
############

# Perl 5
cd /usr/ports/lang/perl514/ && make install clean BATCH=yes
pkg_add -r p5-DBD-mysql55 p5-Authen-Libwrap p5-IO-Tty p5-libwww p5-Net-OpenSSH p5-Net-SSH2 p5-Net-SSLeay p5-perl-ldap p5-String-Multibyte p5-Mail-SpamAssassin

# Python


# Ruby
#pkg_add -r ruby

##############
### Divers ###
##############


# SubVersion
#pkg_add -r subversion

# Mail
#pkg_add -r fetchmail procmail

# ftp
#pkg_add -r proftpd proftpd-mysql

# Web
#pkg_add -r lighttpd


# Divers
#pkg_add -r krb5 bind96 pdflib

# Port manager
#pkg_add -r managepkg portmaster portupgrade

# securité
#pkg_add -r openssl openldap-client nss ca_root_nss nss_mdns      





#################
### Web Panel ###
#################

# Web Panel
#pkg_add -r phpvirtualbox phpmyadmin webalizer




# reste a faire :
# Network Services

# Bind
#named_enable="YES"

# OpenVPN
#openvpn_enable="YES"

# CUPS
#cupsd_enable="YES"

### Web Services
# Lighttpd
#lighttpd_enable="YES"


#java
#upgrade tout le system

##############
### Reboot ###
##############

echo "reboot necessaire (shutdown -r now) !!"
