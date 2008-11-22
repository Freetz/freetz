[ "$FREETZ_PACKAGE_INETD" == "y" -a "$FREETZ_HAS_AVM_INETD" == "y" ] || return 0

echo1 "removing AVM inetd"

rm_files "${FILESYSTEM_MOD_DIR}/bin/inetdctl"

# don't start inetd in rc.S
sed -i -e '\@^/usr/sbin/inetd.*$@d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
