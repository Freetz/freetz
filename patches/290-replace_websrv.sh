[ "$FREETZ_REMOVE_WEBSRV" == "y" ] || return 0

echo1 "removing AVM websrv"
rm_files $(ls -1 "${FILESYSTEM_MOD_DIR}/sbin/websrv")

if [ "$FREETZ_REMOVE_UPNP_LIBS" == "y" ]; then
	echo1 "removing libwebsrv.so"
	rm_files $(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libwebsrv.so*)
fi
