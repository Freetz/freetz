cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/fstab"

# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>               <dump>  <pass>
proc            /proc           proc    nosuid,nodev,noexec     0       0
tmpfs           /var            tmpfs   defaults                0       0
sysfs           /sys            sysfs   nosuid,nodev,noexec     0       0

EOF
