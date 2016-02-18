if [ "$FREETZ_REPLACE_OPENSSL" == "y" -a "${FREETZ_LIBRARY_DIR}" != "/lib" ]; then
	if [ "$FREETZ_LIB_libcrypto" == "y" ]; then
		echo1 "removing avm's libcrypto and create symlinks"
		rm_files "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.0.9.8"
		ln -sf "${FREETZ_LIBRARY_DIR}/libcrypto.so.0.9.8" "${FILESYSTEM_MOD_DIR}/lib/libcrypto.so.0.9.8"
	fi
	if [ "$FREETZ_LIB_libssl" == "y" ]; then
		echo1 "removing avm's libssl and create symlinks"
		rm_files "${FILESYSTEM_MOD_DIR}/lib/libssl.so.0.9.8"
		ln -sf "${FREETZ_LIBRARY_DIR}/libssl.so.0.9.8" "${FILESYSTEM_MOD_DIR}/lib/libssl.so.0.9.8"
	fi
fi
