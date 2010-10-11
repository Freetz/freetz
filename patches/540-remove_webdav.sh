[ "$FREETZ_PACKAGE_DAVFS2" == "y" -o "$FREETZ_REMOVE_WEBDAV" == "y" ] || return 0

echo1 "removing AVM webdav files"
for files in \
	lib/libexpat.so* \
	lib/libneon.so* \
	sbin/*mount.davfs \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

# TODO: Remove "Online-Speicher" from webinterface

if [ "$FREETZ_REMOVE_WEBDAV" == "y" ]; then
	echo1 "patching rc.conf"
	modsed "s/CONFIG_WEBDAV=.*$/CONFIG_WEBDAV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi
