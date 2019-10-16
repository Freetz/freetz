[ "$FREETZ_PATCH_MODFS_ANNEX_SELECTION" = "y" ] || return 0

echo1 "unhiding Annex selection"
modsed -r 's,^([ \t]*export[ \t]+CONFIG_DSL_MULTI_ANNEX)="?n"?[ \t]*$,\1="y",' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
