[ "$FREETZ_REMOVE_ASSISTANT" == "y" ] || return 0
# from m*.* mod
echo1 "removing assistant"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then 
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi
rm_files "${HTML_DIR}/first" \
	 "${HTML_DIR}/konfig" \
	 "${HTML_LANG_MOD_DIR}/html/index_assi.html" \
	 "${HTML_LANG_MOD_DIR}/html/assistent.html"
find "${HTML_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuAssistent/d'

if [ -e "$HTML_DIR/home/sitemap.html" ]; then
	if [ "$FREETZ_HAS_PHONE" == "y" ]; then
		if [ "$FREETZ_TYPE_FON_WLAN_7170" == "y" -a "$FREETZ_TYPE_LABOR_ALL" == "y" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_7170_labor_all.patch"
		else
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant.patch"
		fi
	else	
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_wop.patch"
	fi
fi
