[ "$FREETZ_AVM_HAS_NOEXEC" == "y" ] || return 0
echo1 "dropping noexec"

files="${FILESYSTEM_MOD_DIR}/etc/init.d/S15-filesys ${FILESYSTEM_MOD_DIR}/etc/boot.d/ubi_functions ${FILESYSTEM_MOD_DIR}/etc/boot.d/yaffs_functions"
[ "$FREETZ_DROP_NOEXEC_EXTERNAL" == "y" ] && files="$files ${FILESYSTEM_MOD_DIR}/etc/init.d/rc.mount.sh ${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd"
for file in $files; do
	[ -e "$file" ] && modsed -r "s|([ \t,;'\"])no(exec[ \t,;'\"])|\1\2|g" "$file"
done

