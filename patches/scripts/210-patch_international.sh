[ "$FREETZ_PATCH_INTERNATIONAL" == "y" ] || return 0
# from http://www.the-construct.com/
echo1 "applying international patch"
modsed "s/LKZ 0/LKZ 1/g" "${HTML_SPEC_MOD_DIR}/fon/sip1.js"
