[ "$FREETZ_PATCH_VCC" == "y" ] || return 0
echo1 "applying vcc patch"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then 
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi
if [ "$FREETZ_TYPE_SPEEDPORT_W501V" == "y" ] || \
	[ "$FREETZ_TYPE_SPEEDPORT_W701V" == "y" ]|| \
	[ "$FREETZ_TYPE_SPEEDPORT_W901V" == "y" ]; then
	sed -i -e "s/avme/tcom/g" "${HTML_DIR}/fon/sipoptionen.js"
else
	sed -i -e "s/avme/1und1/g" "${HTML_DIR}/fon/sipoptionen.js"
fi

