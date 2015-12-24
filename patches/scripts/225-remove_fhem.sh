[ "$FREETZ_REMOVE_FHEM" = "y" ] || return 0

echo1 "removing fhem"
rm_files \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-fhem-usb \
  ${MODULES_DIR}/kernel/drivers/usb/class/cdc-acm.ko \
  ${MODULES_DIR}/kernel/drivers/usb/serial/ftdi_sio.ko
