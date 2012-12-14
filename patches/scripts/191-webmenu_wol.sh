[ "$FREETZ_PACKAGE_WOL_CGI" == "y" ] || return 0
echo1 "applying wol patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/${FREETZ_TYPE_LANGUAGE}/webmenu-wol-${FREETZ_TYPE_PREFIX}.patch"

