#!/bin/sh

. /usr/scripts/bsd_flavour.conf


#cd $scripts
cd /usr/scripts

svnlite checkout $source_install_svn/usr/scripts .
chmod -R +x *

svnlite checkout $source_install_svn/root /root
cp /root/cshrc /root/.cshrc

echo " " >> /usr/scripts/journal.log
echo " scripts mis à jour : " >> /usr/scripts/journal.log
date -u >> /usr/scripts/journal.log