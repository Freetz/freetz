[ "$DS_REMOVE_ASSISTANT" == "y" ] || return 0
# from m*.* mod
echo1 "removing assistant"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then 
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi
rm -rf "${HTML_DIR}/first"
rm -f "${HTML_LANG_MOD_DIR}/html/index_assi.html"
rm -f "${HTML_LANG_MOD_DIR}/html/assistent.html"
find "${HTML_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuAssistent/d'

[ -e "$HTML_DIR/home/sitemap.html" ] && \
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_assistant.patch"
