[ "$DS_REMOVE_HELP" == "y" ] || return 0
# from m*.* mod
echo1 "removing help"
rm -rf "${HTML_LANG_MOD_DIR}/help"
find "${HTML_LANG_MOD_DIR}/menus" -type f |
	xargs sed -s -i -e '/var:menuHilfe/d'
sed -i -e '/setvariable var:txtHelp/d' "${HTML_LANG_MOD_DIR}/global.inc"
find "${HTML_LANG_MOD_DIR}/.." -name "*.html" -type f |
	xargs sed -s -i -e '/<input type="button" onclick="uiDoHelp/d'

# Known special case with nested curly braces -> match until next function
# definition, but make sure that the latter is not deleted (exclude from range
# by using an sed 'b' branch command)
#
# TODO: This is a nightmare and a typical problem of "sed patches". To fix this
# properly we would need a real parser capable of exactly matching and removing
# a (JavaScript) function definition.
find "${HTML_LANG_MOD_DIR}/.." -name "wds.js" -type f |
	xargs sed -s -i -e '/function uiDoHelp/, /^function/ { /^function uiDoHelp/d; /^function/b; d }'

# Delete remaining function definitions without nested curly braces
find "${HTML_LANG_MOD_DIR}/.." -name "*.js" -type f |
	xargs sed -s -i -e '/function uiDoHelp/,/^}/d'

find "${HTML_LANG_MOD_DIR}/js" -name "*.js" -type f |
	xargs sed -s -i -e '/function jslPopHelp(pagename) {/,/}/d'

