[ "$FREETZ_UCLIBC_0_9_28_BASED_BOX" == "y" ] && version="0.9.28"
[ "$FREETZ_UCLIBC_0_9_29_BASED_BOX" == "y" ] && version="0.9.29"
[ "$FREETZ_UCLIBC_0_9_32_BASED_BOX" == "y" ] && version="0.9.32"
[ "$FREETZ_UCLIBC_0_9_33_BASED_BOX" == "y" ] && version="0.9.33.2"

echo1 "removing uClibc-${version} files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/*${version}*"

echo1 "removing uClibc links"
for link in \
  ld-linux.so* \
  ld-uClibc.so* \
  ld.so* \
  libc.so* \
  libcrypt.so* \
  libdl.so* \
  libld-uClibc* \
  libm.so* \
  libnsl.so* \
  libpthread.so* \
  libthread_db.so* \
  libresolv.so* \
  librt.so* \
  libubacktrace.so* \
  libutil.so* \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/lib/$link"
	rm_files "${FILESYSTEM_MOD_DIR}/usr/lib/$link"
done

echo1 "linking ld.so.1"
ln -sf ld-uClibc-${FREETZ_TARGET_UCLIBC_VERSION}.so ${FILESYSTEM_MOD_DIR}/lib/ld.so.1
