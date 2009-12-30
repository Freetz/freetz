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
	if isFreetzType 3270 3270_V3 7112 7141 7150 7170 7240 7270 7270_V3; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/remove_assistant_${FREETZ_TYPE_STRING}.patch"
	elif isFreetzType 7140; then
		if isFreetzType LANG_A_CH; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_7170.patch"
		else
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant.patch"
		fi
	elif [ "$FREETZ_HAS_PHONE" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant_wop.patch"
	fi
fi
