[ "$DS_PATCH_SIGNED" == "y" ] || return 0
echo1 "applying webmenu signed patch"

if [ "$DS_TYPE_LANG_STRING" == "de" ] || [ "$DS_TYPE_LANG_STRING" == "a-ch" ] ; then
	sed -i -e "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.js
elif [ "$DS_TYPE_LANG_STRING" == "en" ]; then
	sed -i -e "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/avme/en/html/en/home/home.js
fi

