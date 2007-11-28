[ "$DS_PATCH_ENUM" == "y" ] || return 0
# from http://www.the-construct.com/
echo1 "applying enum patch"
if [ "$DS_TYPE_SPEEDPORT_W501V" == "y" ] || \
	[ "$DS_TYPE_SPEEDPORT_W701V" == "y" ]|| \
	[ "$DS_TYPE_SPEEDPORT_W901V" == "y" ]; then
	sed -i -e "s/avme/tcom/g" "${HTML_LANG_MOD_DIR}/fon/sipoptionen.js"
else
	sed -i -e "s/avme/avm/g" "${HTML_LANG_MOD_DIR}/fon/sipoptionen.js"
fi

