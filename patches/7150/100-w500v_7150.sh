# Partially copied from sp-to-fritz by spirou & jpascher

isFreetzType W500V_7150 || return 0 

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for W500V"

echo2 "copying W500V files"
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip_top.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"
cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip-dsl.bin" "${FILESYSTEM_MOD_DIR}/lib/modules"
#cp "${DIR}/.tk/original/filesystem/etc/init.d/rc.init" "${FILESYSTEM_MOD_DIR}/etc/init.d"
cp "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"

echo2 "deleting obsolete files"
for i in fs/jffs2 fs/ext2 fs/fat fs/isofs fs/nls fs/vfat fs/mbcache.ko drivers/usb drivers/scsi; do
	rm -rf ${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/$i
done
for i in bin/pause bin/usbhostchanged etc/hotplug \
		sbin/lsusb sbin/printserv etc/hotplug sbin/ftpd \
		etc/usb* usr/share/ctlmgr/libctlusb.so sbin/hotplug; do
	rm -rf ${FILESYSTEM_MOD_DIR}/$i
done
echo2 "Add dect sites to webmenu" 
modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/sp2fritz_W500V_7150.patch" 

echo2 "moving default config dir, creating tcom symlinks"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7150" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W500V"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W500V/tcom"

echo2 "patching rc.S and rc.init"
sed -i -e "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x4c /" \
	-e "/ piglet_irq_gpio.*$/d" \
	-e "/ piglet_irq.*$/d" \
	-e "s/isIsdnTE 1 /isIsdnTE 0 /" \
	-e "s/isUsbHost 1 /isUsbHost 0 /" \
	-e "s/isUsbStorage 1 /isUsbStorage 0 /" \
	-e "s/isUsbWlan 1 /isUsbWlan 0 /" \
	-e "s/isUsbPrint 1 /isUsbPrint 0 /" \
	-e "s/dect_hw=3/dect_hw=1/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e "s/^HW=106/HW=91/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"

sed -i -e "s/VERSION_MAJOR=27/VERSION_MAJOR=38/g" \
	-e "s/CAPI_TE=y/CAPI_TE=n/g" \
	-e "s/PRODUKT=.*$/PRODUKT=Fritz_Box_DECT_W500V/g" \
	-e "s/PRODUKT_NAME=.*$/PRODUKT_NAME=Sinus#W#500V/g" \
	-e "s/USB_HOST_AVM=y.*$/USB_HOST_AVM=n USB_STORAGE=n USB_WLAN_AUTH=n USB_PRINT_SERV=n/g" \
	-e "s/SERVICEPORTAL_URL=/SERVICEPORTAL_URL=http:\/\/www.ip-phone-forum.de/g" \
	-e "s/ATA=.*$/ATA=y/g" \
	-e "s/MAILER=.*$/MAILER=y/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"

echo2 "patching webinterface"
HTML_DIR="${HTML_LANG_MOD_DIR}/html/${FREETZ_TYPE_LANG_STRING}"
sed -i -e "s/g_txtmld_/g_txtMld_/g" "${HTML_DIR}/fon/foncalls.js"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${HTML_DIR}/fon/sip1.js"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${HTML_DIR}/fon/siplist.js"
sed -i -e "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${HTML_DIR}/internet/authform.html"
