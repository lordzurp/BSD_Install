########################
### Install X server ###
########################
# Xorg & xfce
pkg_add -r xorg xorg-drivers liberation-fonts-ttf xfce4

# X packages
pkg_add -r bitstream-vera chromium xfe xfce4-media thunar-volman leafpad gedit

# Configure X
cd /root/
X -configure
mv xorg.conf.new /etc/X11/xorg.conf

# Localisation
cd /usr/local/etc/hal/fdi/policy/
fetch https://raw.github.com/lordzurp/Zurpatator2/master/misc/x11-input.fdi
echo 'setenv LANG fr_FR.UTF-8' >> /etc/csh.login
echo 'setenv MM_CHARSET UTF-8' >> /etc/csh.login
echo 'setenv LC_ALL fr_FR.UTF-8' >> /etc/csh.login

# installe les drivers Nvidia (g210 inside)
cd /tmp
tar xzf NVIDIA-FreeBSD-x86_64-275.09.07.tar.gz && cd NVIDIA-FreeBSD-x86_64-275.09.07 && make install