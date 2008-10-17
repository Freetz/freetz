[ "$FREETZ_TARGET_UCLIBC_VERSION" == "0.9.29" ] || return 0
echo1 "removing uClibc-0.9.28 files"
ln -sf ld-uClibc-0.9.29.so ${FILESYSTEM_MOD_DIR}/lib/ld.so.1
rm_files $(find ${FILESYSTEM_MOD_DIR}/lib -maxdepth 1 -type f -name '*0.9.28*')

