[ "$FREETZ_REMOVE_NTFS" == "y" ] || [ "$FREETZ_PACKAGE_NTFS" == "y" ] || return 0

echo1 "remove AVM's ntfs-3g files"
rm_files "${FILESYSTEM_MOD_DIR}/lib/libntfs-3g.so.4917.0.0"
rm_files "${FILESYSTEM_MOD_DIR}/lib/libntfs-3g.so"
rm_files "${FILESYSTEM_MOD_DIR}/lib/libntfs-3g.so.4917"
rm_files "${FILESYSTEM_MOD_DIR}/bin/ntfs-3g"

if [ "$FREETZ_REMOVE_NTFS" == "y" ]; then
	echo1 "patching rc.conf"
	modsed "s/CONFIG_NTFS=.*$/CONFIG_NTFS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi
