[ "$DS_PATCH_LABOR_DSL" == "y" ] || return 0

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/webmenu-labor_dsl.patch"