[ "$DS_REMOVE_HELP" == "y" ] || return 0
# from m*.* mod
echo1 "removing help"
HTML_DIR="${HTML_LANG_MOD_DIR}/html/${DS_TYPE_LANG_STRING}"
echo1 "${HTML_DIR}"
rm -rf "${HTML_DIR}/help"
find "${HTML_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuHilfe/d'
sed -i -e '/setvariable var:txtHelp/d' "${HTML_DIR}/global.inc"
find "${HTML_DIR}/.." -name "*.html" -type f |
	xargs sed -s -i -e '/<input type="button" onclick="uiDoHelp/d'

# Remove functions "uiDoHelp*"
find "${HTML_DIR}/.." -name '*.js' -type f |
	xargs -I '{}' "$TOOLS_DIR/developer/remove_js_function.sh" "{}" "uiDoHelp[[:alpha:]]*"

# Remove functions "jslPopHelp*"
find "${HTML_DIR}/js" -name '*.js' -type f |
	xargs -I '{}' "$TOOLS_DIR/developer/remove_js_function.sh" "{}" "jslPopHelp[[:alpha:]]*"
