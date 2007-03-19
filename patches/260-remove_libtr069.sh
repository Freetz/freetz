if [ "$DS_REMOVE_LIBTR069" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing avm's libtr069.so"
	rm -f "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so"
fi
