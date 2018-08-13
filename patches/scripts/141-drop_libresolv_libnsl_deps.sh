if [ "$FREETZ_AVM_VERSION_07_0X_MIN" = "y" -a "$FREETZ_AVM_HAS_USB_HOST" = "y" ]; then
	echo1 "dropping libresolv and libnsl dependency from binaries/libraries"
	${TOOLS_DIR}/patchelf --remove-needed libresolv.so.1 ${FILESYSTEM_MOD_DIR}/lib/libsamba.so
	${TOOLS_DIR}/patchelf --remove-needed libresolv.so.1 ${FILESYSTEM_MOD_DIR}/sbin/ftpd
	${TOOLS_DIR}/patchelf --remove-needed libnsl.so.1 ${FILESYSTEM_MOD_DIR}/sbin/ftpd
fi
