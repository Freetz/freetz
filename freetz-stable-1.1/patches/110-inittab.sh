cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/inittab"
#
::restart:/sbin/init
::sysinit:/etc/init.d/rc.S

# Start an "askfirst" shell on the console (whatever that may be)
ttyS0::askfirst:-/bin/sh

# Stuff to do before rebooting
::shutdown:/bin/sh -c /var/post_install


EOF
