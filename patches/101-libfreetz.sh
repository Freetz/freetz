[ "$FREETZ_LIB_libfreetz" == "y" ] || return 0

file=${FILESYSTEM_MOD_DIR}/etc/init.d/S01-head
if [ -e $file ]; then
	echo1 "patching /etc/init.d/S01-head"
else
	file=${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S
	echo1 "patching /etc/init.d/rc.s"
fi

modsed 's/export PATH runlevel prevlevel.*$/LD_PRELOAD="libfreetz.so.1.0.0"\ \
export PATH runlevel prevlevel LD_PRELOAD/' $file
