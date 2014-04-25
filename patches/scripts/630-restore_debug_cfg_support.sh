[ "${FREETZ_TYPE_FIRMWARE_04_XX}" == y ] && return 0

grep -q "mknod /var/flash/debug.cfg" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" 2>/dev/null && return 0

echo1 "restoring support for /var/flash/debug.cfg"
modsed '/echo 1 > \/proc\/sys\/kernel\/panic_on_oops/ a\
########################################################################################## \
## user rc file \
########################################################################################## \
if [ -z "$CPU_NR" ] || [ "$CPU_NR" = "1" ] ; then \
mknod /var/flash/debug.cfg c $tffs_major $((0x62)) \
if ! /usr/bin/checkempty /var/flash/debug.cfg 2>/dev/null; then \
. /var/flash/debug.cfg \
fi \
fi' \
"${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"
