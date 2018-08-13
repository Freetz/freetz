isFreetzType 7590 || return 0

if [ "$FREETZ_AVM_UCLIBC_1_0_14" = "y" ]; then
	${TOOLS_DIR}/patchelf --remove-needed libresolv.so.1 ${FILESYSTEM_MOD_DIR}/lib/libsamba.so
	${TOOLS_DIR}/patchelf --remove-needed libresolv.so.1 ${FILESYSTEM_MOD_DIR}/sbin/ftpd
	${TOOLS_DIR}/patchelf --remove-needed libnsl.so.1 ${FILESYSTEM_MOD_DIR}/sbin/ftpd
fi
