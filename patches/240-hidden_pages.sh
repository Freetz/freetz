[ "$FREETZ_PATCH_AVM_HIDDEN_PAGES" == "y" ] || return 0

if [ "$FREETZ_PATCH_HIDDEN_DSL_PAGES" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/webmenu-avm_hidden_dsl_pages.patch"
fi
if [ "$FREETZ_PATCH_HIDDEN_REMOTE_PAGES" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/webmenu-avm_hidden_remote_pages.patch"
fi
