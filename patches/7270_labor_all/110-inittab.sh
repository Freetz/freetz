cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/inittab"
#
::sysinit:/etc/init.d/rc.S

# Start an "askfirst" shell on the console (whatever that may be)
::askfirst:-/bin/sh

# Stuff to do before rebooting
::shutdown:/bin/sh -c /var/post_install


EOF
