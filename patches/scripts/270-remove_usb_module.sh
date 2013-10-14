[ "$FREETZ_REMOVE_USB_MODULE" == "y" ] || return 0
echo1 "removing avalanche_usb.ko"
rm_files "${MODULES_DIR}/kernel/drivers/net/avm_usb/avalanche_usb.ko"
