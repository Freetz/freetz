if [ "$FREETZ_LIB_libcrypto" == "y" ]; then
	echo1 "removing avm's libcrypto"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so" \
		 "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.1" \
		 "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.0.9.8"
fi
if [ "$FREETZ_LIB_libssl" == "y" ]; then
	echo1 "removing avm's libssl"
	rm_files "${FILESYSTEM_MOD_DIR}/lib/libssl.so" \
		 "${FILESYSTEM_MOD_DIR}/lib/libssl.so.1" \
		 "${FILESYSTEM_MOD_DIR}/lib/libssl.so.0.9.8"
fi
