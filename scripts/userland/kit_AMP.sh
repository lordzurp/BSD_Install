# mySQL
	pkg_add -r mysql55-client mysql55-server  pam-mysql libnss-mysql p5-DBD-mysql55
	cd /usr/local/bin
	mysql_install_db --user=mysql --basedir=/usr/local --databasedir=/var/db/mysql
	touch /var/log/mysqld.log
	cd /usr/local/etc/
	fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/my.conf
	echo '# mysql' >> /etc/rc.conf
	echo 'mysql_enable="YES"' >> /etc/rc.conf
	echo '' >> /etc/rc.conf


# Apache
pkg_add -r apache22 ap22-mod_security
cd /usr/local/etc/apache22/
fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/httpd.conf
cd /usr/local/www/
cp -Rlp /usr/local/www/apache22/cgi-bin /usr/local/www
cp -Rlp /usr/local/www/apache22/error /usr/local/www
cp -Rlp /usr/local/www/apache22/html /usr/local/www
cp -Rlp /usr/local/www/apache22/icons /usr/local/www
cp -Rlp /usr/local/www/apache22/usage /usr/local/www
rm -r /usr/local/www/apache22
echo '# apache22' >> /etc/rc.conf
echo 'apache22_enable="YES"' >> /etc/rc.conf
echo '' >> /etc/rc.conf

# PHP 5
#	pkg_add -r php5 php5-bsdconv php5-bz2 php5-ctype php5-filter php5-gd php5-iconv php5-json php5-mbstring php5-mcrypt php5-mysql php5-openssl php5-session php5-xml php5-zip php5-zlib

#fetch https://raw.github.com/lordzurp/Zurpatator2/master/usr_conf/avahi.services/web.service