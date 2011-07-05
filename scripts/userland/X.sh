########################
### Install X server ###
########################
# Xorg & xfce
pkg_add -r xorg xorg-drivers liberation-fonts-ttf xfce4

# X utils
pkg_add -r bitstream-vera

# X packages
pkg_add -r chromium xfe xfce4-media thunar-volman leafpad gedit

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
