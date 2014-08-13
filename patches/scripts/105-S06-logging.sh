[ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ] || return 0

echo1 "adding /etc/init.d/S06-logging"

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/init.d/S06-logging"
#!/bin/sh

# Load boot loader kernel_args API
. /usr/bin/kernel_args
# Backup kernel log ring buffer ASAP, so as not to lose its earliest entries
if ka_isActiveVariable SaveKernelRingBuffer; then
	ka_decreaseValue SaveKernelRingBuffer
	dmesg > /var/dmesg-rc.S.log
fi
# Initiate inotify-tools file access logging
if ka_isActiveVariable InotifyBootAnalysis; then
	ka_decreaseValue InotifyBootAnalysis
	/etc/init.d/rc.inotify_tools start
fi
EOF
