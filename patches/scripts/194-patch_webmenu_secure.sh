[ "$FREETZ_PATCH_SECURE" == "y" ] || return 0
echo1 "applying webmenu secure patch"
 
for oem in $(supported_brandings) all; do
	[ -d "${FILESYSTEM_MOD_DIR}/usr/www/${oem}" -a ! -L "${FILESYSTEM_MOD_DIR}/usr/www/${oem}" ] || continue
	for file in /usr/www/${oem}/home/home.js; do
		[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
		modsed 's/data[.]fritzos[.]twofactor_disabled/false/g;s/data[.]fritzos[.]ipphone_from_outside/false/g' ${FILESYSTEM_MOD_DIR}${file}
	done
done

