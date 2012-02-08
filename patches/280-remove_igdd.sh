[ "$FREETZ_REMOVE_UPNP" == "y" ] || return 0

echo1 "removing AVM UPnP daemon (igdd or upnpd)"
rm_files $(find ${FILESYSTEM_MOD_DIR}/sbin -maxdepth 1 -type f -name upnpd -o -name igdd | xargs) \
	 $(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name 'any.xml' -o -name 'fbox*.xml') \
	 $(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name '*igd*')
[ "$FREETZ_REMOVE_UPNP_LIBS" == "y" ] && rm_files $(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libavmupnp*)
