rm_files()
{
	for file in $1; do
		echo2 "$file"
		rm -rf "$file"
	done
}

[ "$FREETZ_REMOVE_DECT_UPDATE" == "y" ] || return 0
echo1 "removing dect_update"
rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/dect_update"
