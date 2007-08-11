if [ "$DS_PATCH_WDS" == "y" ]
then
	# from m*.* mod
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying wds patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/menu2_wlan.html-wds.patch"
fi
