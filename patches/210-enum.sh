if [ "$DS_PATCH_ENUM" == "y" ]
then
	# from http://www.the-construct.com/
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying enum patch"
	sed -i -e "s/avme/avm/g" "${HTML_MOD_DIR}/fon/sipoptionen.html"
	sed -i -e "s/avme/avm/g" "${HTML_MOD_DIR}/fon/sipoptionen.js"

	if [ "$DS_TYPE_SPEEDPORT_W701V" == "y" ]; then
		sed -i -e "s/avm/tcom/g" "${HTML_MOD_DIR}/fon/sipoptionen.html"
		sed -i -e "s/avm/tcom/g" "${HTML_MOD_DIR}/fon/sipoptionen.js"
	fi
fi
