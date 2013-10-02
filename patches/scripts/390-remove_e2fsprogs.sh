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
  libblkid* \
  libcom_err* \
  libe2p* \
  libext2fs* \
  libuuid* \
  ; do
	for filenpath in $(find ${FILESYSTEM_MOD_DIR}/lib/ ${FILESYSTEM_MOD_DIR}/usr/lib/ -name $files); do
		rm_files "$filenpath"
	done
done
