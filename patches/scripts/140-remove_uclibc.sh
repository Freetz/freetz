[ "$FREETZ_KEEP_AVM_UCLIBC" == "y" ] && return 0

[ "$FREETZ_AVM_UCLIBC_0_9_28" == "y" ] && version="0.9.28"
[ "$FREETZ_AVM_UCLIBC_0_9_29" == "y" ] && version="0.9.29"
[ "$FREETZ_AVM_UCLIBC_0_9_32" == "y" ] && version="0.9.32"
[ "$FREETZ_AVM_UCLIBC_0_9_33" == "y" ] && version="0.9.33.2"

[ -z "$version" ] && error 1 "FREETZ_AVM_UCLIBC is not configured"

echo1 "removing uClibc-${version} files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/*${version}*"
[ "${FREETZ_AVM_HAS_INNER_OUTER_FILESYSTEM}" == "y" ] && rm_files "${FILESYSTEM_OUTER_MOD_DIR}/lib/*${version}*"

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

	if [ "${FREETZ_AVM_HAS_INNER_OUTER_FILESYSTEM}" == "y" ]; then
		rm_files "${FILESYSTEM_OUTER_MOD_DIR}/lib/$link"
		rm_files "${FILESYSTEM_OUTER_MOD_DIR}/usr/lib/$link"
	fi
done

echo1 "linking ld.so.1"
ln -sf ld-uClibc-${FREETZ_TARGET_UCLIBC_VERSION}.so ${FILESYSTEM_MOD_DIR}/lib/ld.so.1
