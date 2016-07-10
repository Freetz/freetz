if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" ]; then
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/init.d/S99-zzz-rcmod"
# Emergency stop switch for execution of Freetz as a whole
[ "$ds_off" == "y" ] || . /etc/init.d/rc.mod 2>&1 | tee /var/log/mod.log
EOF

else
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	# Emergency stop switch for execution of Freetz as a whole
	echo '[ "$ds_off" == "y" ] || . /etc/init.d/rc.mod 2>&1 | tee /var/log/mod.log' >> "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# Emergency stop switch for execution of debug.cfg
modsed -r 's,(if[ \t]+)([!][ \t]*(/usr/bin/)?checkempty[ \t]+/var/flash/debug[.]cfg),\1[ "$dbg_off" != "y" ] \&\& \2,' $rcfile
