#!/bin/sh

cd /usr/ports/sysutils/ezjail/ && make install clean
cd /usr/ports/net/openntpd/ && make install clean


########################
### ajouts à /etc/rc.conf
########################

cat << EOF >> /etc/rc.conf
#########
# EZ Jail
#########
ezjail_enable="YES"
openntpd_enable="YES"

# Jail interface aliases
ifconfig_em1_alias0="inet 192.168.42.101 netmask 255.255.255.0"

rpc_bind_enable="NO"
sendmail_enable="NO"

EOF
########################

################################
### Installation de la base jail
################################
# Clean
chflags -R noschg /usr/obj/*
rm -rf /usr/obj/*
cd /usr/src
make clean

# Récuperer les sources à jour
svn checkout svn://svn.freebsd.org/base/releng/9.1 /usr/src

# Compile le nouveau monde
make buildworld -j5

ezjail-admin update -i

################################
### Default Flavour
################################
# on copie l'example
cp -Rp /usr/jails/flavours/example /usr/jails/flavours/default

# Copie des fichiers de config
cp /etc/resolv.conf /usr/jails/flavours/default/etc/resolv.conf
cp /etc/localtime /usr/jails/flavours/default/etc/localtime

cat << EOF9 > /usr/jails/flavours/default/etc/rc.conf
# Miscellaneous Configuration
network_interfaces="lo0"                # No network interfaces aside from the loopback device
kern_securelevel_enable="YES"           # Enable 'securelevel' kernel security
kern_securelevel="1"                    # See init(8)
rpcbind_enable="NO"                     # Disable RPC daemon
cron_flags="$cron_flags -J 15"          # Prevent lots of jails running cron jobs at the same time
syslogd_flags="-ss"                     # Disable syslogd listening for incoming connections
sendmail_enable="NONE"                  # Comppletely disable sendmail
clear_tmp_enable="YES"                  # Clear /tmp at startup

## Mail Config
#postfix_enable="YES"                    # Enable postfix at boot.
sendmail_enable="NO"                    # Disable Sendmail
sendmail_submit_enable="NO"             # Disable sendmail submit
sendmail_outbound_enable="NO"           # Disable sendmail outbound
sendmail_msp_queue_enable="NO"          # Disable sendmail msp queing

# SSHD Configuration
sshd_enable="YES"                       # Enable sshd

EOF9

cat << EOF > /usr/jails/flavours/default/etc/periodic.conf
daily_status_network_enable="NO"
daily_status_security_ipfwlimit_enable="NO"
daily_status_security_ipfwdenied_enable="NO"
weekly_whatis_enable="NO"       # our jails are read-only /usr

daily_clean_hoststat_enable="NO"
daily_status_mail_rejects_enable="NO"
daily_status_include_submit_mailq="NO"
daily_submit_queuerun="NO"

daily_show_empty_output="NO"
daily_show_success="NO"
daily_show_info="NO"
daily_status_security_inline="YES"

weekly_show_success="NO"
weekly_show_info="NO"
weekly_show_empty_output="NO"

monthly_show_success="NO"
#monthly_show_info="NO" # Show login accounting
monthly_show_empty_output="NO"

EOF

cat << EOF > /usr/jails/flavours/default/ezjail.flavour
#!/bin/sh
#
# BEFORE: DAEMON
#
# Prevent this script from being called over and over if something fails.

rm -f /etc/rc.d/ezjail-config.sh /ezjail.flavour

# blowfish for password hash
echo "crypt_default=blf" >> /etc/auth.conf
sed -i '' s/md5/blf/ /etc/login.conf
# on recrée la base des logins
cap_mkdb /etc/login.conf

# Groups
#########
#
# You will probably start with some groups your users should be in

pw groupadd -q -n admin -g 100

### ADMIN Accounts
echo -n 'password' |\
pw useradd -n admin -u 100 -s /bin/bash -m -d /home/admin -g admin -G wheel -c 'Admin' -h 0


# Packages
###########


# Postinstall
##############
#
# Your own stuff here, for example set login shells that were only 
# installed just before.

# on set le password pour root
echo "Password for root account : "
passwd root

# Create all.log and console.log (chmod all.log, too)
touch /var/log/all.log && chmod 0600 /var/log/all.log
touch /var/log/console.log

EOF

chmod +x /usr/jails/flavours/default/ezjail.flavour

# config /usr/local/etc/ezjail.conf
cat << EOF > /usr/local/etc/ezjail.conf
# ezjail.conf - Example file, see ezjail.conf(5)
ezjail_jaildir=/usr/jails
ezjail_jailtemplate=${ezjail_jaildir}/newjail
ezjail_jailbase=${ezjail_jaildir}/basejail
ezjail_sourcetree=/usr/src
# ezjail_portscvsroot=freebsdanoncvs@anoncvs.FreeBSD.org:/home/ncvs
# ezjail_ftphost=ftp.freebsd.org
# ezjail_default_execute="/usr/bin/login -f root"
ezjail_default_flavour="default"
ezjail_archivedir="${ezjail_jaildir}/ezjail_archives"
ezjail_uglyperlhack="YES"
ezjail_mount_enable="YES"
ezjail_devfs_enable="YES"
# ezjail_devfs_ruleset="devfsrules_jail"
ezjail_procfs_enable="YES"
ezjail_fdescfs_enable="YES"
ezjail_use_zfs="YES"
ezjail_jailzfs="sys_tank/ezjail"
ezjail_zfs_properties="-o compression=lzjb -o atime=off"

EOF

# End of File


