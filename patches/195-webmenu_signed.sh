[ "$FREETZ_PATCH_SIGNED" == "y" ] || return 0
echo1 "applying webmenu signed patch"

if isFreetzType LANG_DE; then
	if isFreetzType 3270 3270_V3 7240 7270 7320 7390 || ( isFreetzType 7170 && isFreetzType LABOR_PREVIEW); then
		modsed "s/^g_coninf_data.FirmwareSigned = .*/g_coninf_data.FirmwareSigned = \"1\"/g" ${FILESYSTEM_MOD_DIR}/usr/www/all/home/home.lua
	else
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.js
	fi
elif isFreetzType LANG_A_CH; then
	if isFreetzType 7270; then
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/html/de/home/home.js
	else
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.js
	fi
elif isFreetzType LANG_EN; then
	if isFreetzType 7340 7390; then
		modsed "s/^g_coninf_data.FirmwareSigned = .*/g_coninf_data.FirmwareSigned = \"1\"/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/home/home.lua
	elif isFreetzType 5124 7113 7140 7170 7270 7570; then
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/html/de/home/home.js
	else
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/en/html/en/home/home.js
	fi
fi

