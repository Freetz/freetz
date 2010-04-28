[ "$FREETZ_PATCH_USBSTORAGE" == "y" ] || return 0
echo1 "applying USB storage patch"
if isFreetzType 7140 && isFreetzType LANG_A_CH; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/a-ch/usbstorage_7140_a_ch.patch"
elif isFreetzType 7140 && isFreetzType LANG_EN; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/en/usbstorage_7140_en.patch"
elif isFreetzType 7170 && isFreetzType LANG_A_CH; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/a-ch/usbstorage_7170_a_ch.patch"
elif isFreetzType 7170 && isFreetzType LANG_EN; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/en/usbstorage_7170_en.patch"
elif isFreetzType 2170 3130 3131 3170 3270 3270_V3 5124 7140 7141 7150 7170 7240 7270 7270_V3 7570 ; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/usbstorage_${FREETZ_TYPE_STRING}.patch"
else
	error 1 "Missing usbstorage patch for $FREETZ_TYPE_STRING - $FREETZ_TYPE_LANG_STRING"
fi

# load ext2 and ext3 modules
modsed '/modprobe vfat/a \
modprobe ext2 \
modprobe ext3 \
modprobe reiserfs' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

# replace rm -rf $dir with rmdir $dir
sed -i 's/rm -rf /rmdir /g' "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage" \
	"${FILESYSTEM_MOD_DIR}/etc/hotplug/run_mount"

# remove all lines with "chmod 000"
modsed "/chmod 000.*$/d" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"

# fix AVM typo, lsmod output is usb_storage
modsed "s/lsmod | grep usb-storage/lsmod | grep usb_storage/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
