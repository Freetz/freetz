[ "$FREETZ_PATCH_MODFS_MULTIPAGE_FAX" = "y" ] || return 0

fax_send_lua_counter=0
for oem in $(supported_brandings) all; do
	www_oem="${FILESYSTEM_MOD_DIR}/usr/www/${oem}"
	[ -d "${www_oem}" -a ! -L "${www_oem}" ] || continue

	fax_send_lua="${www_oem}/fon_devices/fax_send.lua"
	[ -e "${fax_send_lua}" ] || continue

	[ "${fax_send_lua_counter}" -eq 0 ] && echo1 "adding support for sending multi-page faxes"
	fax_send_lua_counter=$((fax_send_lua_counter+1))

	modsed -r 's,(<input type="file")( id="uiFile"[^>]+>),\1 multiple="multiple"\2,' "${fax_send_lua}"
done
