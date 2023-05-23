LOG_DIR=/var/log/permissions
DATE=$(date +'%Y-%m-%d_%H-%M-%S')

if [ ! -d "$LOG_DIR" ]; then
    mkdir $LOG_DIR
    chmod 0600 $LOG_DIR
fi


#--------- expire users
USERLIST=$(grep -oE '^[^:]+' /etc/master.passwd)
for user in $USERLIST
do
    if ! grep -x -q $user /usr/libexec/_hardening/conf/users-who-dont-expire.conf; then
        usermod -e 1 $user
    fi
done
#--------- END OF expire users


#--------- remove suid
SUID_FILE=$LOG_DIR/suid_$DATE.perm
find / -perm -u=s >> $SUID_FILE
while IFS=: read _path; do
    chmod u-s $_path
done < $SUID_FILE
if [ $(awk 'END { print NR }' ${SUID_FILE}) == "0" ]; then
    echo "No SUID found."
    rm $SUID_FILE
else
    chmod 0400 $SUID_FILE
    echo "New SUID permissions backup: $SUID_FILE"
fi
#--------- END OF remove suid


#--------- remove sgid
SGID_FILE=$LOG_DIR/sgid_$DATE.perm
find / -perm -g=s >> $SGID_FILE
while IFS=: read _path; do
    chmod g-s $_path
done < $SGID_FILE
if [ $(awk 'END { print NR }' ${SGID_FILE}) == "0" ]; then
    echo "No SGID Found."
    rm $SGID_FILE
else
    chmod 0400 $SGID_FILE
    echo "New SGID permissions backup: $SGID_FILE"
fi
#--------- END OF remove sgid


#--------- permissions enforce manually
while IFS=" " read _perm _path; do
    _char=$(echo "${_perm}" | cut -c 1)
    if [ "$_char" != "#" ] && [ "$_char" != "" ] && [ "$_char" != " " ]; then
        chmod $_perm $_path
    fi
done < /usr/libexec/_hardening/conf/permissions-enforce.conf
#--------- END OF permissions enforce manually


#--------- change group owner bin-_x11
BIN_GROUP_X11=$LOG_DIR/group_bin-_x11_$DATE.perm
find /usr/X11R6 -follow -type f -perm -o+x -group bin >> $BIN_GROUP_X11
while IFS=: read _path; do
    # every bin is g=rx in this folder,
    # lets change group owner
    chmod g-w $_path
    chown root:_x11 $_path
done < $BIN_GROUP_X11
if [ $(awk 'END { print NR }' ${BIN_GROUP_X11}) == "0" ]; then
    echo "No x11 bin owned by bin GROUP found."
    rm $BIN_GROUP_X11
else
    chmod 0400 $BIN_GROUP_X11
    echo "New _x11 group owner modification backup: $BIN_GROUP_X11"
fi
#--------- END OF change group owner bin-_x11


#--------- remove world (o) perms
BIN_FILE=$LOG_DIR/bin_$DATE.perm
BIN_FILE_TMP=$LOG_DIR/bin_$DATE.perm.tmp
find /bin -follow -type f -perm -o+x >> $BIN_FILE_TMP
find /dev -follow -type f -perm -o+x >> $BIN_FILE_TMP
find /sbin -follow -type f -perm -o+x >> $BIN_FILE_TMP
find /usr/bin -follow -type f -perm -o+x >> $BIN_FILE_TMP
find /usr/games -type f -perm -o+x >> $BIN_FILE_TMP
find /usr/libexec -follow -type f -perm -o+x >> $BIN_FILE_TMP
find /usr/local -not \( -path /usr/local/lib -prune \) -follow -type f -perm -o+x >> $BIN_FILE_TMP
find /usr/mdec -type f -perm -o+x >> $BIN_FILE_TMP
find /usr/sbin -follow -type f -perm -o+x >> $BIN_FILE_TMP
find /usr/X11R6 -type f -perm -o+x >> $BIN_FILE_TMP
find /etc/rc.d -type f -perm -o+x >> $BIN_FILE_TMP
find /etc/X11 -type f -perm -o+x >> $BIN_FILE_TMP

if [ $(awk 'END { print NR }' ${BIN_FILE_TMP}) != "0" ]; then
    while IFS=: read _bin_path; do
        # continue/ignore if $_bin_path is in conf/permissions-enforce.conf
        if grep -q $_bin_path /usr/libexec/_hardening/conf/permissions-enforce.conf; then
            continue
        fi

        _bin_path_perm=$(stat -f "%Sp" $_bin_path)
    
        # if its a link, follow him and override _bin_path with target path
        #     && override _bin_path_perm too.
        if [ $(echo "${_bin_path_perm}" | cut -c 1) == "l" ]; then
            _bin_path=$(readlink -f "${_bin_path}")
            _bin_path_perm=$(stat -f "%Sp" $_bin_path)
        fi

        _bin_path_perm_num=$( echo $_bin_path_perm | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf("0%0o ",k)}')
        echo "$_bin_path_perm_num $_bin_path" >> $BIN_FILE
    done < $BIN_FILE_TMP
    rm $BIN_FILE_TMP

    if [ -e $BIN_FILE ]; then
        if [ $(awk 'END { print NR }' ${BIN_FILE}) != "0" ]; then
            while IFS=" " read _perm _path; do
                chmod o-rwx $_path
            done < $BIN_FILE

            chmod 0400 $BIN_FILE
            echo "New BIN permissions backup: $BIN_FILE"
        fi
    else
        echo "No world executable binary Found. (2)"
    fi
else
    echo "No world executable binary Found. (1)"
    rm $BIN_FILE_TMP
fi
#--------- END OF remove world (o) perms


#
# Fix "system utilities" group owner because any bin is not world executable
#---
# _pkgfetch
if ! grep -q g_fetch /etc/group; then
    groupadd -g 7201 g_fetch
    usermod -G g_fetch _pkgfetch
    chmod g-w          /usr/bin/ftp
    chown root:g_fetch /usr/bin/ftp
fi
#---
# _syspatch
if ! grep -q g_sysutil /etc/group; then
    groupadd -g 7202 g_sysutil
    usermod -G g_sysutil _syspatch
    chmod g-w            /usr/bin/signify
    chown root:g_sysutil /usr/bin/signify
    chmod g-w            /bin/cksum
    chown root:g_sysutil /bin/cksum
fi
#
# Currently "system utilities" seems to not handle secondary groups
# It's reported, we'll see.
# Until fix you have to set o+rx before using pkd_add or syspatch by example
#
