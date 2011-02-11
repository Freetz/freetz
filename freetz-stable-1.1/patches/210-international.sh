[ "$FREETZ_PATCH_INTERNATIONAL" == "y" ] || return 0
# from http://www.the-construct.com/
echo1 "applying international patch"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi
modsed "s/LKZ 0/LKZ 1/g" "${HTML_DIR}/fon/sip1.js"

