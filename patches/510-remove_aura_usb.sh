[ "$FREETZ_REMOVE_AURA_USB" == "y" ] || return 0
echo1 "removing aura-usb files"
for files in \
 	bin/aurad \
	bin/auracntl \
	bin/aurachanged \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

