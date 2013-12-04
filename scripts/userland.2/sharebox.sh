#!/bin/sh

# installe netatalk et samba
# veiller à ajouter l'option 'PAM' lors de la config
portinstall -c avahi netatalk samba36 samba36-libsmbclient pam_smb

# installe les fichiers de config
cp /usr/local/etc/afpd.conf /usr/local/etc/afpd.conf.dist
cat << EOF > /usr/local/etc/afpd.conf
# default:
- -tcp -noddp  -savepassword -uamlist uams_dhx.so,uams_dhx2.so,uams_guest.so,uams_clrtxt.so 
"timemachine" -tcp -noddp -port 12002 -savepassword -defaultvol /usr/local/etc/AppleVolumes.timemachine -uamlist uams_dhx.so,uams_dhx2.so,uams_guest.so,uams_clrtxt.so

EOF

cp /usr/local/etc/netatalk.conf /usr/local/etc/netatalk.conf.dist
cat << EOF > /usr/local/etc/netatalk.conf
# netatalk configuration
AFPD_MAX_CLIENTS=20
ATALK_NAME=`/bin/hostname -s`
ATALK_MAC_CHARSET='MAC_ROMAN'
ATALK_UNIX_CHARSET='LOCALE'
AFPD_GUEST="media"

EOF

cp /usr/local/etc/AppleVolumes.default /usr/local/etc/AppleVolumes.default.dist
cat << EOF > /usr/local/etc/AppleVolumes.default
:DEFAULT: options:upriv,usedots
~
/home/media "MediaTeK" rolist:@public_user rwlist:@user
/home/docs "Docs communs" allow:"Ti_nicO","aurel"

EOF

cat << EOF > /usr/local/etc/AppleVolumes.timemachine
/home/timemachine/MacZurp "timemachine" allow:"Ti nicO" options:tm volsizelimit:250000
EOF

echo 'lagg0' >> /usr/local/etc/atalkd.conf

cp /usr/local/etc/smb.conf /usr/local/etc/smb.conf.dist
cat << EOF > /usr/local/etc/smb.conf
[global]
	dns proxy = No
	log file = /var/log/samba/log.%m
	netbios name = Zurpatator2
	server string = Zurpatator2
	guest account = media
	workgroup = WORKGROUP
	security = user
	os level = 20
	null passwords = yes
	encrypt passwords = yes
	max log size = 50

[Ti_nicO]
	comment = Ti nicO Docs
	path = /home/Ti_nicO
	valid users = "Ti_nicO"
	public = no
	writable = yes
	printable = no
	
[Aurel]
	comment = Aurel Docs
	path = /home/aurel
	valid users = "aurel"
	public = no
	writable = yes
	printable = no

[Mediatheque]
	path = /home/media
	comment = Mediatheque
	public = yes
	writable = yes
	printable = no
	write list = @user

[public]
   path = /home/public
   public = yes
   only guest = yes
   writable = yes
   printable = no
EOF

chmod 644 /usr/local/etc/smb.conf

# installe les services dans avahi
cp /usr/local/etc/avahi-daemon.conf /usr/local/etc/avahi-daemon.conf.dist
cat << EOF > /usr/local/etc/avahi-daemon.conf
# avahi-daemon.conf

[server]
host-name=z2.sharebox
#domain-name=lan
browse-domains=0pointer.de, zeroconf.org
use-ipv4=yes
use-ipv6=no
#allow-interfaces=eth0
#deny-interfaces=eth1
#check-response-ttl=no
#use-iff-running=no
enable-dbus=yes
#disallow-other-stacks=no
#allow-point-to-point=no
#cache-entries-max=4096
#clients-max=4096
#objects-per-client-max=1024
#entries-per-entry-group-max=32
ratelimit-interval-usec=1000000
ratelimit-burst=1000

[wide-area]
enable-wide-area=yes

[publish]
#disable-publishing=no
#disable-user-service-publishing=no
#add-service-cookie=no
#publish-addresses=yes
#publish-hinfo=yes
publish-workstation=no
publish-domain=yes
publish-dns-servers=192.168.1.1
#publish-resolv-conf-dns-servers=yes
#publish-aaaa-on-ipv4=yes
#publish-a-on-ipv6=no

[reflector]
#enable-reflector=no
#reflect-ipv=no

[rlimits]
#rlimit-as=
rlimit-core=0
rlimit-data=4194304
rlimit-fsize=0
rlimit-nofile=768
rlimit-stack=4194304
rlimit-nproc=3

EOF

cd /usr/local/etc/avahi/services
cat << EOF > /usr/local/etc/avahi/services/backup.timemachine.service
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<service-group>
	<name replace-wildcards="yes">TimeMachine</name>

	<service>
		<type>_afpovertcp._tcp</type>
		<port>12002</port>
	</service>

	<service>
		<type>_device-info._tcp</type>
		<port>0</port>
		<txt-record>model=TimeCapsule</txt-record>
	</service>

	<service>
		<type>_adisk._tcp</type>
		<port>0</port>
		<txt-record>sys=waMA=00:e0:81:b7:58:7a,adVF=0x100</txt-record>
		<txt-record>dk0=adVF=0x83,adVN=TimeMachine</txt-record>
	</service>
	
</service-group>

EOF

cat << EOF > /usr/local/etc/avahi/services/service.netatalk.service
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<service-group>
  <name replace-wildcards="yes">%h</name>

  <service>
    <type>_afpovertcp._tcp</type>
    <port>548</port>
  </service>

  <service>
    <type>_device-info._tcp</type>
    <port>0</port>
    <txt-record>model=MacPro</txt-record>
  </service>

</service-group>
EOF

cat << EOF > /usr/local/etc/avahi/services/service.samba.service
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">

<service-group>
  <name replace-wildcards="yes">%h</name>

  <service>
    <type>_smb._tcp</type>
    <port>445</port>
  </service>
  
  <service>
    <type>_device-info._tcp</type>
    <port>0</port>
    <txt-record>model=MacPro</txt-record>
  </service>

</service-group>
EOF



# configure les daemons dans /etc/rc.conf
cat << EOF >> /etc/rc.conf
hostname="zurpatator2"

# Avahi
avahi_daemon_enable="YES"
avahi_dnsconfd_enable="YES"

# Netatalk & AFP
netatalk_enable="YES"
afpd_enable="YES"
cnid_metad_enable="YES"

# Samba
samba_enable="YES"

EOF



# Configure le système
cd /etc
ln -s ../usr/local/etc/smb.conf
ln -s ..//usr/local/etc/samba
cd rc.d
ln -s ../../usr/local/etc/rc.d/samba



