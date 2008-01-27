[ "$DS_REMOVE_ASSISTANT" == "y" ] || return 0
# from m*.* mod
echo1 "removing assistant"
HTML_DIR="${HTML_LANG_MOD_DIR}/html/${DS_TYPE_LANG_STRING}"
rm -rf "${HTML_DIR}/first"
rm -f "${HTML_LANG_MOD_DIR}/html/index_assi.html"
rm -f "${HTML_LANG_MOD_DIR}/html/assistent.html"
find "${HTML_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuAssistent/d'

