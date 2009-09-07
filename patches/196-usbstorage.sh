[ "$FREETZ_PATCH_USBSTORAGE" == "y" ] || return 0
echo1 "applying USB storage patch"
if isFreetzType 2170 3131 W900V; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_3170.patch"
elif isFreetzType 3130; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_wotam.patch"
elif isFreetzType 7141; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_7170_a_ch.patch"
elif isFreetzType 3170 3270 7141 7150 7170 7240 7270 7270_V3; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_${FREETZ_TYPE_STRING}.patch"
elif isFreetzType 7140; then
	if isFreetzType LANG_A_CH; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_7170.patch"
	elif isFreetzType LANG_DE; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_wotam.patch"
	elif isFreetzType LANG_EN; then \
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_3170.patch"
	fi
else
	error 1 "Missing usbstorage patch for $FREETZ_TYPE_STRING"
fi

# load ext2 and ext3 modules
sed -i -e '/modprobe vfat/a \
\t\tmodprobe ext2 \
\t\tmodprobe ext3 \
\t\treiserfs' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

# replace rm -rf $dir with rmdir $dir
sed -i 's/rm -rf /rmdir /g' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage" \
	"${FILESYSTEM_MOD_DIR}/etc/hotplug/run_mount"

# remove all lines with "chmod 000"
sed -i -e "/chmod 000.*$/d" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

# fix AVM typo, lsmod output is usb_storage
sed -i -e "s/lsmod | grep usb-storage/lsmod | grep usb_storage/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
