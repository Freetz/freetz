if [ "$DS_LIB_libcrypto" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing avm's libcrypto"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.1"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.0.9.8"
	#disable tr069
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}patching tr069.cfg"
	find ${FILESYSTEM_MOD_DIR}/etc -name tr069.cfg -exec sed -e 's/enabled = yes/enabled = no/' -i '{}' \;
fi
if [ "$DS_LIB_libssl" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing avm's libssl"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libssl.so"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libssl.so.1"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libssl.so.0.9.8"
fi
