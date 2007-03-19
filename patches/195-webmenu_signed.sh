if [ "$DS_PATCH_SIGNED" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying webmenu signed patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/195-webmenu_signed.patch"
fi
