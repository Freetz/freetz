rm_files()
{
	for file in $1; do
		echo2 "$file"
		rm -f "$file"
	done
}

if [ "$FREETZ_REMOVE_WEBSRV" == "y" ]; then
	echo1 "removing AVM websrv"
	rm_files "$(ls -1 "${FILESYSTEM_MOD_DIR}/sbin/websrv")"
fi

if [ "$FREETZ_REMOVE_UPNP" == "y" ]; then
	echo1 "removing AVM UPnP daemon (igdd)"
	rm_files "$(ls -1 ${FILESYSTEM_MOD_DIR}/sbin/igdd)"
	if [ "$FREETZ_REMOVE_UPNP_LIBS" == "y" ]; then
		rm_files "$(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libavmupnp*)"
	fi
		rm_files "$(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name 'any.xml' -o -name 'fbox*.xml')"
		rm_files "$(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name '*igd*')"
fi

if [ "$FREETZ_REMOVE_WEBSRV" == "y" ] && [ "$FREETZ_REMOVE_UPNP_LIBS" == "y" ]; then
	echo1 "removing libwebsrv.so"
	rm_files "$(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libwebsrv.so*)"
fi
