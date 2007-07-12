if [ "$DS_PATCH_SIGNED" == "y" ]
then
	echo1 "applying webmenu signed patch"
	sed -i -e "s/^.*var signed.*/\tvar signed = 1;/g" ${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/home/home.js
fi
