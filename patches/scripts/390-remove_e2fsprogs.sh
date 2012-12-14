[ "$FREETZ_REMOVE_AVM_E2FSPROGS" == "y" ] || return 0

echo1 "remove AVM's e2fsprogs binaries"
for files in \
  blkid \
  e2fsck \
  fsck* \
  mke2fs \
  mkfs* \
  mkswap \
  ; do
	for filenpath in $(find ${FILESYSTEM_MOD_DIR}/sbin/ ${FILESYSTEM_MOD_DIR}/usr/sbin/ -name $files); do
		rm_files "$filenpath"
	done
done

echo1 "remove AVM's e2fsprogs libraries"
for files in \
  usr/lib/libblkid* \
  usr/lib/libcom_err* \
  usr/lib/libe2p* \
  usr/lib/libext2fs* \
  usr/lib/libuuid* \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
