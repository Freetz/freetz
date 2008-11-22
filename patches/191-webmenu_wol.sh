[ "$FREETZ_PACKAGE_WOL_CGI" == "y" ] || return 0
echo1 "applying wol patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_LANG_STRING}/webmenu-wol-${FREETZ_TYPE_STRING}.patch"

