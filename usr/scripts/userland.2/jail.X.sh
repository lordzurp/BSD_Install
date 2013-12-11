########################
### Install X server ###
########################

# Xorgx
portinstall -c xorg xorg-drivers liberation-fonts-ttf x11/nvidia-driver nvidia-xconfig nvidia-settings gnome2-lite

# Configure X
cd /root/
X -configure
mv xorg.conf.new /etc/X11/xorg.conf
nvidia-xconfig

echo 'nvidia_load="YES"' >> /boot/loader.conf
# Localisation
cd /usr/local/etc/hal/fdi/policy/
fetch http://192.168.1.96/zurp_fs/misc/x11-input.fdi
echo 'setenv LANG fr_FR.UTF-8' >> /etc/csh.login
echo 'setenv MM_CHARSET UTF-8' >> /etc/csh.login
echo 'setenv LC_ALL fr_FR.UTF-8' >> /etc/csh.login


echo "exec ck-launch-session gnome-session" >> /root/.xinitrc

