[ "$FREETZ_PATCH_ENUM" == "y" ] || return 0
echo1 "applying enum patch"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi

WS0='[ \t]*'
for l in $(sed -ne '/ui[a-zA-Z]*Enum/ =' "${HTML_DIR}/fon/sipoptionen.js"); do
	modsed "$((l-1)) s,g_Oem${WS0}==${WS0}\"avme\",true,g" "${HTML_DIR}/fon/sipoptionen.js"
done
unset WS0

if isFreetzType W501V W701V W901V; then
	modsed "s/avme/tcom/g" "${HTML_DIR}/fon/sipoptionen.js"
fi
