[ "$FREETZ_REMOVE_AVM_E2FSPROGS" == "y" ] || return 0

# Note: all AVM binaries are actually from util-linux package
# mkswap, swapon, swapoff, renice are replaced with their busybox counterparts

echo1 "remove AVM's e2fsprogs/util-linux binaries"
for files in \
  blkid \
  chcpu \
  e2fsck \
  findmnt \
  fsck* \
  losetup \
  lsblk \
  mke2fs \
  mkfs* \
  mkswap \
  mountpoint \
  renice \
  swapon \
  swapoff \
  wdctl \
  ; do
	for filenpath in $(find ${FILESYSTEM_MOD_DIR}/{bin,sbin,usr/bin,usr/sbin}/ -name $files); do
		rm_files "$filenpath"
	done
done

echo1 "remove AVM's e2fsprogs/util-linux libraries"
for files in \
  libblkid* \
  libcom_err* \
  libe2p* \
  libext2fs* \
  libmount* \
  libuuid* \
  ; do
	for filenpath in $(find ${FILESYSTEM_MOD_DIR}/{lib,usr/lib}/ -name $files); do
		rm_files "$filenpath"
	done
done
