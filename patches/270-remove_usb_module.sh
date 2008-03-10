[ "$FREETZ_REMOVE_USB_MODULE" == "y" ] || return 0
echo1 "removing avalanche_usb.ko"
rm -f "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ar7/kernel/drivers/net/avm_usb/avalanche_usb.ko"

