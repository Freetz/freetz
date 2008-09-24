[ "$FREETZ_REMOVE_TR069" == "y" ] || return 0

rm_files()
{
	for file in $1; do
	echo2 "$file"
	rm -rf "$file"
	done
}

echo1 "removing tr069 stuff"
rm_files "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so"
rm_files "${FILESYSTEM_MOD_DIR}/bin/tr069starter"
rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/tr069fwupdate"

