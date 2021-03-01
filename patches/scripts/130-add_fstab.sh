
echo1 "creating fstab"

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/fstab"
## /etc/fstab: static file system information.
## <file system>  <mount point>  <type>  <options>                 <dump>  <pass>

# AVM
tmpfs             /var           tmpfs   defaults                  0       0
/dev/root         /              auto    defaults,errors=continue  0       0
proc              /proc          proc    nosuid,nodev,noexec       0       0

# MOD
sysfs             /sys           sysfs   nosuid,nodev,noexec       0       0
devpts            /dev/pts       devpts  mode=0620,gid=5           0       0

EOF

VARFS="$(sed -rn 's,^([^ \t]*)[ \t]*/var[ \t].*,\1,p' ${FILESYSTEM_DIR}/etc/fstab)"
[ "$VARFS" != "tmpfs" ] && sed -i "s/tmpfs/$VARFS/g" "${FILESYSTEM_MOD_DIR}/etc/fstab"

