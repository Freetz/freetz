[ "$FREETZ_PATCH_BETA_ATTRIBUTES" == "y" ] || return 0

echo1 "removing Beta/Labor attributes"

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/${FREETZ_TYPE_LANGUAGE}/remove_beta_attributes_${FREETZ_TYPE_PREFIX}.patch"
