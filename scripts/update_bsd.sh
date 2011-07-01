#!/bin/sh

freebsd-update fetch upgrade
freebsd-update install

portsnap fetch update
portsnap extract
portsnap update

cd /usr/ports/lang/gcc46 ; make config-recursive ; make fetch-recursive ; make install clean

portupgrade -N cvsup
mkdir /usr/local/etc/cvsup/
cp /usr/share/examples/cvsup/stable-supfile /usr/local/etc/cvsup
cp /usr/share/examples/cvsup/ports-supfile /usr/local/etc/cvsup

echo 'default host=cvsup1.fr.FreeBSD.org'
ee /usr/local/etc/cvsup/stable-supfile
ee /usr/local/etc/cvsup/ports-supfile

cd /usr/src/
make buildworld



