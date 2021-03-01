[ "$FREETZ_PATCH_INTERNATIONAL" == "y" ] || return 0
echo1 "applying international patch"

# from http://www.the-construct.com/
modsed "s/LKZ 0/LKZ 1/g" "${HTML_SPEC_MOD_DIR}/fon/sip1.js"

