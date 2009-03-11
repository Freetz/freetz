[ "$FREETZ_REMOVE_ASSISTANT" == "y" ] || return 0
# from m*.* mod
echo1 "removing assistant"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then 
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi

rm_files "${HTML_DIR}/konfig" \
	 "${HTML_LANG_MOD_DIR}/html/index_assi.html" \
	 "${HTML_LANG_MOD_DIR}/html/assistent.html"

# Don't delete provider.js because it's referenced by ohter files
find "${HTML_DIR}/first" -type f -not -name "provider.js" -exec rm {} \;

find "${HTML_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuAssistent/d'

if [ -e "$HTML_DIR/home/sitemap.html" ]; then
	if [ "$FREETZ_HAS_PHONE" == "y" ]; then
		if [ "$FREETZ_TYPE_FON_WLAN_7270" == "y" -o "$FREETZ_TYPE_FON_WLAN_7240" == "y" ] && [ "$FREETZ_TYPE_LABOR_PHONE" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_7270_labor_phone.patch"
		elif [ "$FREETZ_TYPE_FON_WLAN_7270" == "y" -a "$FREETZ_TYPE_LABOR_DSL" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/$FREETZ_TYPE_LANG_STRING/remove_assistant_7270_labor_dsl.patch"
		elif [ "$FREETZ_TYPE_FON_WLAN_7240" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/$FREETZ_TYPE_LANG_STRING/remove_assistant_7240.patch"
		elif [ "$FREETZ_TYPE_FON_WLAN_7270" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/$FREETZ_TYPE_LANG_STRING/remove_assistant_7270.patch"
		elif [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_DSL" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_7170_labor_dsl.patch"
		elif [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_AIO" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_7170.patch"
		elif [ "$FREETZ_TYPE_FON_WLAN_7141" == "y" -o "$FREETZ_TYPE_FON_WLAN_7170" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_7170.patch"
		else
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant.patch"
		fi
	else	
		if [ "$FREETZ_TYPE_WLAN_3270" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_3270.patch"
		else
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_wop.patch"
		fi
	fi
fi
