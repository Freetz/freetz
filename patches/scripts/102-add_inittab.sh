# Do not start the shell if it should be disabled
[ "$FREETZ_DISABLE_SERIAL_CONSOLE" == "y" ] && shell="" || shell="-/bin/sh"

# Start Freetz IP watchdog if selected
[ "$FREETZ_REPLACE_ONLINECHANGED" == "y" ] && ip_watchdog="
# Freetz replacement for unreliable AVM onlinechanged
::respawn:/sbin/ip_watchdog
"

# Script for sysinit
[ -n "$SYSTEMD_CORE_MOD_DIR" ] && sysinit="/etc/boot.d/1" || sysinit="/etc/init.d/rc.S"

# actual filesystem
cat << EOF > "${FILESYSTEM_MOD_DIR}/etc/inittab"
::sysinit:$sysinit

# Start an "askfirst" shell on the console (whatever that may be)
${FREETZ_AVM_SERIAL_CONSOLE_DEVICE}::askfirst:$shell
$ip_watchdog
# Stuff to do before rebooting
::shutdown:/bin/sh -c /etc/inittab.shutdown

::restart:/sbin/init
EOF

# wrapper filesystem
if [ "${FREETZ_AVM_HAS_INNER_OUTER_FILESYSTEM}" == "y" ]; then
	# keep all AVM sysinit lines except for that containing /etc/init.d/rc.S (we provide our own)
	sed -i -n -e '/::sysinit:/ { /\/etc\/init\.d\/rc\.S/ !p }' "${FILESYSTEM_OUTER_MOD_DIR}/etc/inittab"
	cat "${FILESYSTEM_MOD_DIR}/etc/inittab" >> "${FILESYSTEM_OUTER_MOD_DIR}/etc/inittab"
fi
