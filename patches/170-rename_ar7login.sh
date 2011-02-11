if [ -f "${FILESYSTEM_MOD_DIR}/sbin/ar7login" ]; then
	echo1 "renaming ar7login to make way for wrapper script"
	mv -f \
		"${FILESYSTEM_MOD_DIR}/sbin/ar7login" \
		"${FILESYSTEM_MOD_DIR}/sbin/ar7login.bin"
else
	echo1 "NOT renaming ar7login (file not found)"
fi
