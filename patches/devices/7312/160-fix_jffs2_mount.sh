# Fix jffs2 mount (no jffs2 module)
modsed "s#modprobe jffs2#grep -q \"jffs2\" /proc/filesystems || modprobe jffs2#g" "${FILESYSTEM_MOD_DIR}/etc/init.d/S15-filesys"
