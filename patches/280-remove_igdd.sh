[ "$FREETZ_REMOVE_UPNP" == "y" ] || return 0

echo1 "removing AVM UPnP daemon (igdd or upnpd)"
rm_files $(find ${FILESYSTEM_MOD_DIR}/sbin -maxdepth 1 -type f -name upnpd -o -name igdd | xargs) \
	 $(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name 'any.xml' -o -name 'fbox*.xml') \
	 $(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name '*igd*')
[ "$FREETZ_REMOVE_UPNP_LIBS" == "y" ] && rm_files $(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libavmupnp*)

_upnp_file="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"
grep -q "^upnpdstart *()" $_upnp_file && _upnp_name=upnpdstart || _upnp_name=igddstart
echo1 "patching rc.net: renaming $_upnp_name()"
modsed "s/^\($_upnp_name *()\)/\1\n{ return; }\n_\1/" "$_upnp_file" "_$_upnp_name"
