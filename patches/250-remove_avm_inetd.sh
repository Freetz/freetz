[ "$FREETZ_PACKAGE_INETD" == "y" -a "$FREETZ_HAS_AVM_INETD" == "y" ] || return 0

echo1 "removing AVM inetd"

rm_files "${FILESYSTEM_MOD_DIR}/bin/inetdctl"

# don't start inetd in rc.S
count=$(grep "usr/sbin/inetd" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S" | wc -l)
if [ $count -gt 1 ]; then
	modsed '/if \[ \-x \/usr\/sbin\/inetd \] \; then/!b;:x1;/fi/!{N;bx1;};d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
else
	modsed '\@^/usr/sbin/inetd.*$@d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi
