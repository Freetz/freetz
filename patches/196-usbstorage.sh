[ "$DS_PATCH_USBSTORAGE" == "y" ] || return 0
echo1 "applying USB storage patch"
if [ "$DS_TYPE_2170" == "y" ] || \
	[ "$DS_TYPE_FON_WLAN_7140" == "y" -a "$DS_TYPE_LANG_DE" == "y" ] || \
	[ "$DS_TYPE_FON_7150" == "y" ] || \
	[ "$DS_TYPE_WLAN_3130" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_wotam.patch"
elif [ "$DS_TYPE_SPEEDPORT_W900V" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_w900v.patch"
elif [ "$DS_TYPE_FON_WLAN_7270" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_7270.patch"
elif [ "$DS_TYPE_FON_WLAN_7170" == "y" -a "$DS_TYPE_LABOR_PHONE" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_7270.patch"
elif [ "$DS_TYPE_FON_WLAN_7170" == "y" -a "$DS_TYPE_LABOR_MINI" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_7270.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage.patch"
fi

sed -i -e '/modprobe vfat/a \
\t\tmodprobe ext2 \
\t\tmodprobe ext3' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

