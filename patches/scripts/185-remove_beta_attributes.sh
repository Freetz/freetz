[ "$FREETZ_PATCH_BETA_ATTRIBUTES" == "y" ] || return 0
echo1 "removing Beta/Labor attributes"

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/185-remove_beta_attributes/remove_beta_attributes_${FREETZ_TYPE_PREFIX}.patch"

