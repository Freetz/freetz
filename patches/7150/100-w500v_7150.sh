# Partially copied from sp-to-fritz by spirou & jpascher

[ "$DS_TYPE_SINUS_W500V_7150" == "y" ] || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for W500V"

echo2 "copying W500V files"
cp "${DIR}/.tk/original/filesystem/etc/init.d/rc.init" "${FILESYSTEM_MOD_DIR}/etc/init.d"
cp "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"

echo2 "deleting obsolete files"
for i in fs drivers/usb drivers/scsi; do
	rm -rf ${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/$i
done
for i in bin/pause bin/reinit_jffs2 bin/pause bin/usbhostchanged etc/hotplug \
		sbin/lsusb sbin/printserv etc/hotplug sbin/ftpd; do
	rm -rf ${FILESYSTEM_MOD_DIR}/$i
done

echo2 "moving default config dir, creating tcom symlinks"
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7150" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_Sinus_W500V"
ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_Sinus_W500V/tcom"

echo2 "patching rc.S and rc.init"
sed -i -e "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x4c /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

sed -i -e "s/BUTTON=y/BUTTON=n/g" \
-e "s/ATA=n/ATA=y/g" \
-e "s/MAILER=.*$/MAILER=y/g" \
-e "s/HOSTNAME=.*$/HOSTNAME=fritz.box/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
sed -i -e '/HW=91 OEM=all XILINX=y/i \
HW=91 OEM=all LED_NO_INFO_LED_KONFIG=y \
HW=91 OEM=all AUDIO=n \
HW=91 OEM=all MEDIASRV=n \
HW=91 OEM=all MEDIACLI=n \
HW=91 OEM=all AURA=n \
HW=91 OEM=all VPN=n \
HW=91 OEM=all KIDS=y \
HW=91 OEM=all SWAP=n \
HW=91 OEM=all ECO=y' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"

echo2 "patching webinterface"
sed -i -e "s/g_txtmld_/g_txtMld_/g" "${HTML_LANG_MOD_DIR}/fon/foncalls.js"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${HTML_LANG_MOD_DIR}/fon/sip1.js"
sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${HTML_LANG_MOD_DIR}/fon/siplist.js"
sed -i -e "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${HTML_LANG_MOD_DIR}/internet/authform.html"
