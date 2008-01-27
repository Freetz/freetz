[ "$DS_PATCH_INTERNATIONAL" == "y" ] || return 0
# from http://www.the-construct.com/
echo1 "applying international patch"
HTML_DIR="${HTML_LANG_MOD_DIR}/html/${DS_TYPE_LANG_STRING}"
sed -i -e "s/LKZ 0/LKZ 1/g" "${HTML_DIR}/fon/sip1.js"

