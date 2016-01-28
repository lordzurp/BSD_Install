#!/bin/sh


# Netatalk 3

pkg install avahi netatalk3



# installe les fichiers de config
cp /usr/local/etc/afpd.conf /usr/local/etc/afpd.conf.dist
cp /usr/local/etc/afpd.conf.zurp /usr/local/etc/afpd.conf

cp /usr/local/etc/netatalk.conf /usr/local/etc/netatalk.conf.dist
cp /usr/local/etc/netatalk.conf.zurp /usr/local/etc/netatalk.conf


cp /usr/local/etc/AppleVolumes.default /usr/local/etc/AppleVolumes.default.dist
cp /usr/local/etc/AppleVolumes.default.zurp /usr/local/etc/AppleVolumes.default


echo 'em0' >> /usr/local/etc/atalkd.conf


# Samba 4

# samba36 samba36-libsmbclient pam_smb


cp /usr/local/etc/smb.conf /usr/local/etc/smb.conf.dist
cp /usr/local/etc/smb.conf.zurp /usr/local/etc/smb.conf

chmod 644 /usr/local/etc/smb.conf

# installe les services dans avahi
cp /usr/local/etc/avahi-daemon.conf /usr/local/etc/avahi-daemon.conf.dist
cp /usr/local/etc/avahi-daemon.conf.zurp /usr/local/etc/avahi-daemon.conf

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



