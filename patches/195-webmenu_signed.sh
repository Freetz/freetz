[ "$FREETZ_PATCH_SIGNED" == "y" ] || return 0
echo1 "applying webmenu signed patch"

if [ "$FREETZ_TYPE_LANG_STRING" == "de" ]; then
	modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.js
elif [ "$FREETZ_TYPE_LANG_STRING" == "a-ch" ]; then
	if isFreetzType 7270; then
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/html/de/home/home.js
	else
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.js
	fi
elif [ "$FREETZ_TYPE_LANG_STRING" == "en" ]; then
	if isFreetzType 7140 7170 7270 7570; then
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/html/de/home/home.js
	else
		modsed "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/en/html/en/home/home.js
	fi
fi

