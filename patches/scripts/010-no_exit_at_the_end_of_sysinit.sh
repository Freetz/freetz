if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" ]; then
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"
else
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

echo1 "removing 'exit 0' at the end of the sysinit script"

# remove 'exit 0' if it's the last non-blank line in the file
modsed -r '
	:collect
	N
	$ !b collect
	s/([ \t]*(exit[ \t]+0)?[ \t\n]*)*$//
' "$rcfile"
