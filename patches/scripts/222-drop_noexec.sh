[ "$FREETZ_DROP_NOEXEC_EXTERNAL" == "y" -o "$FREETZ_DROP_NOEXEC_INTERNAL" == "y" ] || return 0

echo1 "dropping noexec"
[ "$FREETZ_DROP_NOEXEC_EXTERNAL" == "y" ] && file_ext="${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd"
[ "$FREETZ_DROP_NOEXEC_INTERNAL" == "y" ] && file_int="${FILESYSTEM_MOD_DIR}/etc/init.d/S15-filesys"
for file in "$file_ext" "$file_int"; do
	[ -e "$file" ] && modsed 's/, *noexec//g;s/-o  *noexec *,/-o /g;s/-o  *noexec *//g' "$file"
done

