[ -z "$SYSTEMD_CORE_MOD_DIR" ] || return 0
echo1 "removing 'exit 0' at the end of the sysinit script"

if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" ]; then
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"
else
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# remove 'exit 0' if it's the last non-blank line in the file
modsed -r '
	:collect
	N
	$ !b collect
	s/([ \t]*(exit[ \t]+0)?[ \t\n]*)*$//
' "$rcfile"

# remove 'exit' from files sourced from rc.S
if [ "$FREETZ_AVM_VERSION_06_2X_MIN" == "y" ]; then
	[ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/S78-aha" ] && modpatch "${FILESYSTEM_MOD_DIR}" "${PATCHES_COND_DIR}/010-no_exit_in_S78-aha_sourced_from_rc.S.patch"
fi

