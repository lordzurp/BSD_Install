#!/bin/sh

. /usr/scripts/bsd_flavour.conf


#cd $scripts
cd /usr/scripts

svn checkout $source_install_svn/usr/scripts .
chmod -R +x *
