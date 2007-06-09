if [ "$DS_PATCH_SIGNED" == "y" ]
then
	echo1 "applying webmenu signed patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/195-webmenu_signed.patch"
fi
