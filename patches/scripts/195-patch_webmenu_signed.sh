[ "$FREETZ_PATCH_SIGNED" == "y" ] || return 0
echo1 "applying webmenu signed patch"

for file in /usr/www/all/home/home.js /usr/www/avme/home/home.js; do
	[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
	modsed 's/data[.]fritzos[.]FirmwareSigned/true/g' ${FILESYSTEM_MOD_DIR}${file}
done

for file in /usr/www/all/home/home.lua /usr/www/avme/home/home.lua; do
	[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
	modsed 's/^g_coninf_data.FirmwareSigned = .*/g_coninf_data.FirmwareSigned = "1"/g' ${FILESYSTEM_MOD_DIR}${file}
done

for file in /usr/www/all/html/de/home/home.js /usr/www/avme/html/de/home/home.js /usr/www/avme/en/html/en/home/home.js; do
	[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
	modsed 's/^.*var signed.*/\tvar signed = 1;/g' ${FILESYSTEM_MOD_DIR}${file}
done

for file in "${HTML_LANG_MOD_DIR##${FILESYSTEM_MOD_DIR}}/system/diagnosis.lua" /usr/lua/retrieve_data.lua; do
	[ ! -e ${FILESYSTEM_MOD_DIR}${file} ] && continue
	modsed 's,box[.]query("[^"]*/signed_firmware"),"1",g' ${FILESYSTEM_MOD_DIR}${file}
done
