if [ ! $1 ]; then
    echo "Usage: ./add-user-to-group-x11.sh _username"
    exit 1
fi

#---
# x11 stuff
if ! grep -q g_x11 /etc/group; then
    groupadd -g 7001 g_x11
    usermod -G g_x11 _x11
    chmod g-w /usr/X11R6/bin/xterm
    chmod g-w /usr/X11R6/bin/fvwm
    chmod g-w /usr/X11R6/lib/X11/fvwm/Fvwm*
    chmod g-w /etc/X11/xenodm/GiveConsole
    chmod g-w /etc/X11/xenodm/TakeConsole
    chmod g-w /etc/X11/xenodm/Xreset
    chmod g-w /etc/X11/xenodm/Xsession
    chmod g-w /etc/X11/xenodm/Xsetup_0
    chmod g-w /etc/X11/xenodm/Xstartup
    chown root:g_x11 /usr/X11R6/bin/xterm
    chown root:g_x11 /usr/X11R6/bin/fvwm
    chown root:g_x11 /usr/X11R6/lib/X11/fvwm/Fvwm*
    chown root:g_x11 /etc/X11/xenodm/GiveConsole
    chown root:g_x11 /etc/X11/xenodm/TakeConsole
    chown root:g_x11 /etc/X11/xenodm/Xreset
    chown root:g_x11 /etc/X11/xenodm/Xsession
    chown root:g_x11 /etc/X11/xenodm/Xsetup_0
    chown root:g_x11 /etc/X11/xenodm/Xstartup
fi

# add given user arg to g_x11 group
usermod -G g_x11 $1
