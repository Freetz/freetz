if [ "$DS_REMOVE_TR069" == "y" ]
then
	echo1 "removing avm's libtr069.so"
	rm -f "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so"
	rm -f "${FILESYSTEM_MOD_DIR}/bin/tr069starter"
	rm -f "${FILESYSTEM_MOD_DIR}/usr/bin/tr069fwupdate"
fi
