#!/bin/sh

cd /etc/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/sysctl.conf

cd /usr/local/etc/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/afpd.conf
cd /usr/local/etc/ ; fetch http://chez.tinico.free.fr/docs/bsd.conf/netatalk.conf

echo "0   5   *   *   *   root   cd /usr/src && cvsup stable-supfile" >> /etc/crontab


