
if [ -e "${FILESYSTEM_MOD_DIR}/etc/boot.d/core/99-tail" ]; then
	dsfile="${FILESYSTEM_MOD_DIR}/etc/boot.d/core/99-zzz-rcmod"
	rcfile=""
elif [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" ]; then
	dsfile="${FILESYSTEM_MOD_DIR}/etc/init.d/E99-zzz-rcmod"
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"
else
	dsfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# Emergency stop switch for execution of Freetz as a whole
echo '[ "$ds_off" == "y" ] || . /etc/init.d/rc.mod 2>&1 | tee /var/log/mod.log' >> "$dsfile"
chmod +x "$dsfile"

# Emergency stop switch for execution of debug.cfg
[ -n "$rcfile" ] && modsed -r 's,(if[ \t]+)([!][ \t]*(/usr/bin/)?checkempty[ \t]+/var/flash/debug[.]cfg),\1[ "$dbg_off" != "y" ] \&\& \2,' $rcfile
