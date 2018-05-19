[ "$FREETZ_MODIFY_AVM_VERSION" == "y" ] || return 0

echo1 "adding Freetz version to AVM version data"
if [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/system_status-07_0X_MIN.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/system_status-04_XX_MIN.patch"
fi
