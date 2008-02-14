[ "$DS_PATCH_AVM_HIDDEN_PAGES" == "y" ] || return 0

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/webmenu-avm_hidden_pages.patch"