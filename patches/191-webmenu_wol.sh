[ "$DS_PACKAGE_WOL_CGI" == "y" ] || return 0
echo1 "applying wol patch"
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/${DS_TYPE_LANG_STRING}/webmenu-wol-${DS_TYPE_STRING}.patch"

