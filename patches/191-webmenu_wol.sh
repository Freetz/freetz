if [ "$DS_PACKAGE_WOL_CGI" == "y" ]
then
	echo1 "applying wol patch"
	if [ "$DS_TYPE_FON_WLAN_7170" == "y" ]
	then
	    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/191-webmenu-wol-7170.patch"
	elif [ "$DS_TYPE_FON_WLAN_7141" == "y" ]
	then
	    modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/191-webmenu-wol-7141.patch"
	fi
fi
