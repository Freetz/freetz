[ "$FREETZ_REMOVE_JFFS2" = "y" ] || return 0

echo1 "removing jffs2"
rm_files "${MODULES_DIR}/kernel/fs/jffs2"

echo1 "patching rc.conf"
modsed "s/\(CONFIG_JFFS2=\).*$/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
