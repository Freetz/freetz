[ "$DS_PATCH_USBSTORAGE" == "y" ] || return 0
echo1 "applying USB storage patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage.patch"

