[ "$FREETZ_REMOVE_UTIL_LINUX" == "y" ] || return 0

echo1 "remove AVM's blikd, fsck, mkfs"
for files in \
	usr/sbin/blkid \
	usr/sbin/e2fsck \
	usr/sbin/fsck* \
	usr/sbin/mke2fs \
	usr/sbin/mkfs* \
	usr/lib/libblkid* \
	usr/lib/libcom_err* \
	usr/lib/libe2p* \
	usr/lib/libext2fs* \
	usr/lib/libuuid* \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
