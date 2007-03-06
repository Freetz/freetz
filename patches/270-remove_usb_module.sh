if [ "$DS_REMOVE_USB_MODULE" == "y" ]
then
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}removing avalanche_usb.ko"
	rm -f "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ar7/kernel/drivers/net/avm_usb/avalanche_usb.ko"
fi
