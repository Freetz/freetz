[ "$FREETZ_DROP_NOEXEC" == "y" ] || return 0

echo1 "dropping noexec"
for file in "${FILESYSTEM_MOD_DIR}/etc/init.d/S15-filesys" "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mount-sd"; do
	[ -e "$file" ] && modsed 's/, *noexec//g;s/-o  *noexec *,/-o /g;s/-o  *noexec *//g' "$file"
done

