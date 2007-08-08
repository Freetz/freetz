if [ "$DS_PACKAGE_MINI_FO" == "y" ]
then
	echo1 "applying mini_fo patch"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/mini_fo-inittab.patch"
fi
