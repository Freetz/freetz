[ "$FREETZ_REMOVE_FHEM" = "y" ] || return 0

echo1 "removing fhem"
rm_files \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-fhem-usb \
  ${FILESYSTEM_MOD_DIR}/lib/modules/*/kernel/drivers/usb/class/cdc-acm.ko \
  ${FILESYSTEM_MOD_DIR}/lib/modules/*/kernel/drivers/usb/serial/ftdi_sio.ko
