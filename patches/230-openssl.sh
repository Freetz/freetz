if [ "$DS_LIB_libcrypto" == "y" ]; then
	echo1 "removing avm's libcrypto"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.1"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.0.9.8"
fi
if [ "$DS_LIB_libssl" == "y" ]; then
	echo1 "removing avm's libssl"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libssl.so"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libssl.so.1"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/libssl.so.0.9.8"
fi
