[ "$FREETZ_MODIFY_AVM_VERSION" == "y" ] || return 0

echo1 "adding Freetz version to AVM version data"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/system_status.patch"
