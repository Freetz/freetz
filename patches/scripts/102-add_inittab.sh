if isFreetzType 7312 7320 7330; then
	console="/dev/ttyS1" # 7312, 7320 and 7330 all use ttyS1 as serial console
else
	console="/dev/ttyS0"
fi

# Do not start the shell if it should be disabled
[ "$FREETZ_DISABLE_SERIAL_CONSOLE" == "y" ] && shell="" || shell="-/bin/sh"

# Start Freetz IP watchdog if selected
[ "$FREETZ_REPLACE_ONLINECHANGED" == "y" ] && ip_watchdog="
# Freetz replacement for unreliable AVM onlinechanged
::respawn:/sbin/ip_watchdog
"

# actual filesystem
cat << EOF > "${FILESYSTEM_MOD_DIR}/etc/inittab"
::sysinit:/etc/init.d/rc.S

# Start an "askfirst" shell on the console (whatever that may be)
$console::askfirst:$shell
$ip_watchdog
# Stuff to do before rebooting
::shutdown:/bin/sh -c /etc/inittab.shutdown

::restart:/sbin/init
EOF

# wrapper filesystem
if [ "${FREETZ_AVM_HAS_UPDATE_FILESYSTEM_IMAGE}" == "y" ]; then
	# keep all AVM sysinit lines except for that containing /etc/init.d/rc.S (we provide our own)
	sed -i -n -e '/::sysinit:/ { /\/etc\/init\.d\/rc\.S/ !p }' "${FILESYSTEM_CORE_MOD_DIR}/etc/inittab"
	cat "${FILESYSTEM_MOD_DIR}/etc/inittab" >> "${FILESYSTEM_CORE_MOD_DIR}/etc/inittab"
fi
