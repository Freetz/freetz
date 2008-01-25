rm_files()
{
	for file in $1; do
		echo2 "$file"
		rm -rf "$file"
	done
}

[ "$DS_REMOVE_CAPIOVERTCP" == "y" ] || return 0
echo1 "removing capiotcp_server"
rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/capiotcp_server"

