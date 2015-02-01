[ "$FREETZ_REMOVE_PRINTSERV" == "y" ] || return 0

if [ "$FREETZ_PACKAGE_USBIP_WRAPPER" != "y" ]; then
	echo1 "removing AVM's printserver"
	rm_files "${FILESYSTEM_MOD_DIR}/sbin/printserv"
else
	echo1 "replacing AVM's printserver"
	echo '/etc/init.d/rc.usbip reload >/dev/null' > "${FILESYSTEM_MOD_DIR}/sbin/printserv"
fi

rm_files "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-printer-lp"

[ "$FREETZ_REMOVE_PRINTSERV_MODULE" == "y" ] && \
	rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/*/kernel/drivers/usb/class/usblp.ko

# patcht System > Diagnose (ab 5.59)
sedfile="${LUA_MOD_DIR}/usb_devices.lua"
echo1 "patching ${sedfile##*/}"
modsed "s/config\.USB_PRINT_SERV/true/g" $sedfile


echo1 "patching rc.conf"
modsed "s/CONFIG_USB_PRINT_SERV=.*$/CONFIG_USB_PRINT_SERV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
