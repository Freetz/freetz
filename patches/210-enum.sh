[ "$DS_PATCH_ENUM" == "y" ] || return 0
# from http://www.the-construct.com/
echo1 "applying enum patch"
HTML_DIR="${HTML_LANG_MOD_DIR}/html/${DS_TYPE_LANG_STRING}"
if [ "$DS_TYPE_SPEEDPORT_W501V" == "y" ] || \
	[ "$DS_TYPE_SPEEDPORT_W701V" == "y" ]|| \
	[ "$DS_TYPE_SPEEDPORT_W901V" == "y" ]; then
	sed -i -e "s/avme/tcom/g" "${HTML_DIR}/fon/sipoptionen.js"
else
	sed -i -e "s/avme/avm/g" "${HTML_DIR}/fon/sipoptionen.js"
fi

