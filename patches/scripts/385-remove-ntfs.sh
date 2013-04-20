[ "$FREETZ_REMOVE_NTFS" == "y" ] || [ "$FREETZ_PACKAGE_NTFS" == "y" ] || return 0

echo1 "remove AVM's ntfs-3g files"
for files in \
  bin/ntfs-3g \
  lib/libfuse.so* \
  lib/libntfs-3g.so* \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

if [ "$FREETZ_REMOVE_NTFS" == "y" ]; then
	echo1 "patching rc.conf"
	modsed "s/CONFIG_NTFS=.*$/CONFIG_NTFS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
else
	ln -s /usr/bin/ntfs-3g ${FILESYSTEM_MOD_DIR}/bin/ntfs-3g
fi
