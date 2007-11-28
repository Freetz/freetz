[ "$DS_REMOVE_ASSISTANT" == "y" ] || return 0
# from m*.* mod
echo1 "removing assistant"
rm -rf "${HTML_LANG_MOD_DIR}/first"
rm -f "${HTML_LANG_MOD_DIR}/../index_assi.html"
rm -f "${HTML_LANG_MOD_DIR}/../assistent.html"
find "${HTML_LANG_MOD_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuAssistent/d'

