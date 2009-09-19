[ "$FREETZ_LIB_libfreetz" == "y" ] || return 0

echo1 "patching /etc/init.d/rc.s"

modsed 's/export PATH runlevel prevlevel.*$/LD_PRELOAD="libfreetz.so.1.0.0"\ \
export PATH runlevel prevlevel LD_PRELOAD/' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
