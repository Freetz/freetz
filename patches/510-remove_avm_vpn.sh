[ "$FREETZ_REMOVE_AVM_VPN" == "y" ] || return 0
echo1 "removing AVM-VPN files"
for files in \
 	bin/avmike \
	; do
	rm -rf ${FILESYSTEM_MOD_DIR}/$files
done

