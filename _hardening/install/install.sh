#--------- services
#rcctl enable apmd
#rcctl set apmd flags -A
#rcctl start apmd

#rcctl stop dhcpleased
#rcctl disable dhcpleased

rcctl stop ntpd
rcctl disable ntpd

rcctl stop slaacd
rcctl disable slaacd

rcctl stop smtpd
rcctl disable smtpd

rcctl stop sshd
rcctl disable sshd

rcctl stop sndiod
rcctl disable sndiod

rcctl enable xenodm
#--------- END OF services


#--------- copy /etc files
_install_root_path="/usr/libexec/_hardening/install/rootfs"
cp $_install_root_path/etc/fstab.example /etc/
cp $_install_root_path/etc/hostname.bwfm0 /etc/
cp $_install_root_path/etc/installurl /etc/
cp $_install_root_path/etc/mygate /etc/
cp $_install_root_path/etc/pf.conf /etc/
cp $_install_root_path/etc/rc.local /etc/
cp $_install_root_path/etc/resolv.conf /etc/
cp $_install_root_path/etc/sysctl.conf /etc/
cp $_install_root_path/etc/ttys /etc/
cp $_install_root_path/etc/wsconsctl.conf /etc/
cp $_install_root_path/etc/X11/xenodm/Xresources /etc/X11/xenodm/
cp $_install_root_path/etc/X11/xenodm/Xsetup_0 /etc/X11/xenodm/
#--------- END OF copy /etc files

chmod -R 0700 /usr/libexec/_hardening
chmod -R 0600 /usr/libexec/_hardening/conf


