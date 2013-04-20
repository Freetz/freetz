[ "$FREETZ_REMOVE_WEBDAV" == "y" ] || return 0

echo1 "removing AVM webdav files"
for files in \
  lib/libexpat.so* \
  lib/libneon.so* \
  sbin/*mount.davfs \
  etc/onlinechanged/webdav_net \
  etc/webdav_control \
  usr/www/all/html/de/home/home_webdav.txt \
  bin/webdavcfginfo \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

if [ ! "$FREETZ_PACKAGE_DAVFS2" == "y" ]; then
	# TODO: Remove "Online-Speicher" from webinterface and remove usr/www/all/lua/webdav.lua
	rm_files "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libctlwebdav.so"
	echo1 "patching rc.conf"
	modsed "s/CONFIG_WEBDAV=.*$/CONFIG_WEBDAV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi
