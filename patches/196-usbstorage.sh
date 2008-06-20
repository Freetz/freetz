[ "$FREETZ_PATCH_USBSTORAGE" == "y" ] || return 0
echo1 "applying USB storage patch"
if 	[ "$FREETZ_TYPE_FON_WLAN_7140" == "y" -a "$FREETZ_TYPE_LANG_DE" == "y" ] || \
	[ "$FREETZ_TYPE_WLAN_3130" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_wotam.patch"
elif [ "$FREETZ_TYPE_FON_WLAN_7140" == "y" -a "$FREETZ_TYPE_LANG_EN" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/en/usbstorage_7140.patch"
elif [ "$FREETZ_TYPE_2170" == "y" ] || \
	[ "$FREETZ_TYPE_FON_7150" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7140" == "y" -a "$FREETZ_TYPE_LANG_A_CH" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7141" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7170" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7270" == "y" ] || \
	[ "$FREETZ_TYPE_WLAN_3131" == "y" ] || \
	[ "$FREETZ_TYPE_WLAN_3170" == "y" ] || \
	[ "$FREETZ_TYPE_SPEEDPORT_W900V" == "y" ]; then
		if [ "$FREETZ_TYPE_LABOR_GAMING" ]; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_7270_labor_gaming.patch"
		else
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_7270.patch"
		fi
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage.patch"
fi

sed -i -e '/modprobe vfat/a \
\t\tmodprobe ext2 \
\t\tmodprobe ext3' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

