[ "$FREETZ_REMOVE_PUBKEY" == "y" ] || return 0
echo1 "removing public signature"

file="${FILESYSTEM_MOD_DIR}/etc/avm_firmware_public_key1"
rm_files "$file"

[ "$FREETZ_TYPE_EXTENDER" == "y" ] && file="3" || file="4"
file="${FILESYSTEM_MOD_DIR}/etc/avm_firmware_public_key$file"
if [ -e "$file" ]; then
	if [ "$FREETZ_REMOVE_PUBKEY_INHAUS" == "y" ]; then
		rm_files "$file"
	else
		warn "File $file found but not removed"
	fi
fi

