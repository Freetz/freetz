[ "$FREETZ_PATCH_ENUM" == "y" ] || return 0
# from http://www.the-construct.com/
echo1 "applying enum patch"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then 
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi
if isFreetzType W501V W701V W901V; then
	modsed "s/avme/tcom/g" "${HTML_DIR}/fon/sipoptionen.js"
else
	modsed "s/avme/avm/g" "${HTML_DIR}/fon/sipoptionen.js"
fi

