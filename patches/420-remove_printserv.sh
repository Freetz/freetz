[ "$FREETZ_REMOVE_PRINTSERV" == "y" ] || return 0
echo1 "removing AVM's printserver"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/printserv"

[ "$FREETZ_REMOVE_PRINTSERV_MODULE" == "y" ] && \
	rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/*/kernel/drivers/usb/class/usblp.ko

echo1 "patching rc.conf"
modsed "s/CONFIG_USB_PRINT_SERV=.*$/CONFIG_USB_PRINT_SERV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
