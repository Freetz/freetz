# 7320 uses ttyS1 as serial console
isFreetzType 7320 && return 0

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/inittab"
#
::restart:/sbin/init
::sysinit:/etc/init.d/rc.S

# Start an "askfirst" shell on the console (whatever that may be)
ttyS0::askfirst:-/bin/sh

# Stuff to do before rebooting
::shutdown:/bin/sh -c /var/post_install


EOF
