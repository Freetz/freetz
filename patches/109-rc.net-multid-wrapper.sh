[ "$FREETZ_PACKAGE_DNSMASQ_WRAPPER" == "y" ] && MULTID_WRAPPER="dnsmasq"
[ "$FREETZ_PACKAGE_BIND_WRAPPER" == "y" ] && MULTID_WRAPPER="bind"
[ -n "$MULTID_WRAPPER" ] || return 0

echo1 "replacing multid by a wrapper for $MULTID_WRAPPER"
modsed "s#\(^PATH=\)\(.*\)#\1/mod/pkg/$MULTID_WRAPPER/usr/lib/$MULTID_WRAPPER/bin:\2#g" \
 "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"
