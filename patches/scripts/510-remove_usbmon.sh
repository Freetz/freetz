[ "$FREETZ_MODULE_usbmon" == "y" ] && return 0

echo1 "removing usbmon.ko"
rm_files $(find "${FILESYSTEM_MOD_DIR}/lib/modules" -name "usbmon.ko")
