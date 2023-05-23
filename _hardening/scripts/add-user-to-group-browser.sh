if [ ! $1 ]; then
    echo "Usage: ./add-user-to-group-browser.sh _username"
    exit 1
fi

#---
# ungoogled-chromium
if ! grep -q g_browser /etc/group; then
    groupadd -g 7101 g_browser
    chmod -x             /usr/local/bin/ungoogled-chrom*
    chmod g-w            /usr/local/bin/ungoogled-chrom*
    #chown root:bin      /usr/local/bin/ungoogled-chrom*
    chmod u-x            /usr/local/ungoogled-chromium/ungoogled-chromium
    chmod g-w            /usr/local/ungoogled-chromium/ungoogled-chromium
    chown root:g_browser /usr/local/ungoogled-chromium/ungoogled-chromium
    #chmod o-r           /usr/local/ungoogled-chromium/lib*
    chmod g-w            /usr/local/share/icu/73.1/icudt73l.dat
    chown root:g_browser /usr/local/share/icu/73.1/icudt73l.dat
    #
    cp /usr/libexec/_hardening/install/rootfs/usr/local/bin/chromium-* /usr/local/bin/
    chmod 0650 /usr/local/bin/chromium-*
    chown root:g_browser /usr/local/bin/chromium-*
fi

# add given user arg to group g_browser
usermod -G g_browser $1
