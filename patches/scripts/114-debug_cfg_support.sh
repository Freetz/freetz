if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" ]; then
        rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"
else
        rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

if grep -q "mknod /var/flash/debug.cfg" "$rcfile" 2>/dev/null; then
	# firmware supports debug.cfg
	if [ "${FREETZ_DISABLE_DEBUG_CFG_SUPPORT}" == y ]; then
		echo1 "disabling processing of /var/flash/debug.cfg"
		modsed -r 's,^([.][ \t]+/var/flash/debug[.]cfg),: # disabled by freetz: \1,' "$rcfile"
	fi
else
	# no support for debug.cfg
	if [ "${FREETZ_RESTORE_DEBUG_CFG_SUPPORT}" == y ]; then
		echo1 "restoring support for /var/flash/debug.cfg"

modsed '/echo 1 > \/proc\/sys\/kernel\/panic_on_oops/ a\
##########################################################################################\
## user rc file\
##########################################################################################\
if [ -z "$CPU_NR" ] || [ "$CPU_NR" = "1" ] ; then\
mknod /var/flash/debug.cfg c $tffs_major $((0x62))\
if ! /usr/bin/checkempty /var/flash/debug.cfg 2>/dev/null; then\
. /var/flash/debug.cfg\
fi\
fi' \
"$rcfile"

	fi
fi
