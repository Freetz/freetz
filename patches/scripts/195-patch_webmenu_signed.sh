[ "$FREETZ_PATCH_SIGNED" == "y" ] || return 0
echo1 "applying webmenu signed patch"

for oem in $(supported_brandings) all; do
	[ -d "${FILESYSTEM_MOD_DIR}/usr/www/${oem}" -a ! -L "${FILESYSTEM_MOD_DIR}/usr/www/${oem}" ] || continue

	for file in /usr/www/${oem}/home/home.js; do
		[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
		modsed 's/data[.]fritzos[.]FirmwareSigned/true/g' ${FILESYSTEM_MOD_DIR}${file}
	done

	for file in /usr/www/${oem}/home/home.lua; do
		[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
		modsed 's/^g_coninf_data[.]FirmwareSigned = .*/g_coninf_data.FirmwareSigned = "1"/g' ${FILESYSTEM_MOD_DIR}${file}
	done

	for file in /usr/www/${oem}/html/de/home/home.js /usr/www/${oem}/en/html/en/home/home.js; do
		[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
		modsed 's/^.*var signed.*/\tvar signed = 1;/g' ${FILESYSTEM_MOD_DIR}${file}
	done

	for file in /usr/www/${oem}/system/diagnosis.lua /usr/lua/retrieve_data.lua; do
		[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
		modsed 's,box[.]query("[^"]*/signed_firmware"),"1",g' ${FILESYSTEM_MOD_DIR}${file}
	done
done
