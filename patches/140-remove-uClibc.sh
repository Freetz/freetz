( \
	[ "$FREETZ_UCLIBC_0_9_29_BASED_BOX" == "y" ] && [ ! "$FREETZ_TARGET_UCLIBC_VERSION_0_9_29" == "y" ] \
	|| [ "$FREETZ_UCLIBC_0_9_30_BASED_BOX" == "y" ] \
	|| [ "$FREETZ_UCLIBC_0_9_31_BASED_BOX" == "y" ] \
) || return 0

version=
[ "$FREETZ_UCLIBC_0_9_29_BASED_BOX" == "y" ] && version="0.9.29"
[ "$FREETZ_UCLIBC_0_9_30_BASED_BOX" == "y" ] && version="0.9.30"
[ "$FREETZ_UCLIBC_0_9_31_BASED_BOX" == "y" ] && version="0.9.31"

echo1 "removing uClibc-${version} files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/*${version}*"

echo1 "removing uClibc links"
for link in ld-linux.so* ld-uClibc.so* ld.so* libc.so* libcrypt.so* libdl.so* libld-uClibc* libm.so* libnsl.so* libpthread.so* libthread_db.so* \
	libresolv.so* librt.so* libutil.so*; do
	rm_files "${FILESYSTEM_MOD_DIR}/lib/$link"
done

echo1 "linking ld.so.1"
ln -sf ld-uClibc-${FREETZ_TARGET_UCLIBC_VERSION}.so ${FILESYSTEM_MOD_DIR}/lib/ld.so.1
