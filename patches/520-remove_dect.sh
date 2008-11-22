[ "$FREETZ_REMOVE_DECT" == "y" ] || return 0
echo1 "removing DECT files"
for files in \
	lib/modules/2.6.19.2/kernel/drivers/isdn/avm_dect/avm_dect.ko \
	lib/modules/2.6.19.2/kernel/drivers/char/dect_io/dect_io.ko \
	usr/bin/dect_manager \
	usr/share/ctlmgr/libdect.so \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

