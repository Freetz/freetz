[ "$FREETZ_REMOVE_PRINTSERV" == "y" ] || return 0
[ "$FREETZ_PACKAGE_USBIP_WRAPPER" != "y" ] && action='removing' || action='replacing'
echo1 "$action AVM's printserver"

if [ "$FREETZ_PACKAGE_USBIP_WRAPPER" != "y" ]; then
	rm_files "${FILESYSTEM_MOD_DIR}/sbin/printserv"
else
	echo '/etc/init.d/rc.usbip reload >/dev/null' > "${FILESYSTEM_MOD_DIR}/sbin/printserv"
fi

rm_files "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-printer-lp"
supervisor_delete_service "printer"

modsed \
  '/\/etc\/hotplug\/udev-printer-lp/d' \
  "${FILESYSTEM_MOD_DIR}/etc/udev/rules.d/??-usb*.rules"

[ "$FREETZ_REMOVE_PRINTSERV_MODULE" == "y" ] && \
	rm_files ${MODULES_DIR}/kernel/drivers/usb/class/usblp.ko

# patcht System > Diagnose (ab 5.59)
sedfile="${LUA_MOD_DIR}/usb_devices.lua"
echo1 "patching ${sedfile##*/}"
modsed "s/config\.USB_PRINT_SERV/true/g" $sedfile

echo1 "patching rc.conf"
modsed "s/CONFIG_USB_PRINT_SERV=.*$/CONFIG_USB_PRINT_SERV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

