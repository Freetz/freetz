if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" ]; then
        rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"
else
        rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

if grep -q "mknod /var/flash/debug.cfg" "$rcfile" 2>/dev/null; then
	# firmware supports debug.cfg
	if [ "${FREETZ_DISABLE_DEBUG_CFG_SUPPORT}" == y ]; then
		echo1 "disabling processing of /var/flash/debug.cfg"
		modsed -r 's,^([ \t]*[.][ \t]+/var/flash/debug[.]cfg),: # disabled by freetz: \1,' "$rcfile"
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

if [ "$FREETZ_ASYNCHRONOUS_DEBUG_CFG" == "y" ]; then
	if [ ! -x "${FILESYSTEM_MOD_DIR}/sbin/delay" ]; then
		warn "AVM's /sbin/delay is missing, asynchronous processing of /var/flash/debug.cfg is not (yet) possible."
	else
		modsed -r \
			's,^([ \t]*)[.][ \t]+(/var/flash/debug[.]cfg),delay -d 1 DEBUG_CFG "/bin/sh -c \\"eventadd 1 '"'Processing /var/flash/debug.cfg (asynchronously) ... started'"'; sh \2 0</dev/null 1>/var/log/debug_cfg.log 2>\&1; eventadd 1 '"'Processing /var/flash/debug.cfg ... finished'"'\\"",' \
			"$rcfile"
	fi
fi
