cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/inittab"
#
::restart:/sbin/init
::sysinit:/etc/init.d/rc.S

# Start an "askfirst" shell on the console (whatever that may be)
/dev/ttyS1::askfirst:-/bin/sh

# Stuff to do before rebooting
::shutdown:/bin/sh -c /etc/inittab.shutdown

EOF
