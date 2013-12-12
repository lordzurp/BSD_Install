#!/bin/sh

. /usr/scripts/bsd_flavour.conf


#cd $scripts
cd /usr/scripts

svnlite checkout $source_install/usr/scripts .
chmod -R +x *
