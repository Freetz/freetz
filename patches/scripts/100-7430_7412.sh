isFreetzType 7412_7430 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7412"

echo2 "copying 7412 wlan files"
cp -a ${FILESYSTEM_TK_DIR}/etc/default.Fritz_Box_HW209/avm/wlan* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW218/avm/

modules=" net/ath_hal.ko"
#modules=" net/ath_hal.ko net/aae.ko net/asf.ko"
for i in $modules; do
	cp -a "${FILESYSTEM_TK_DIR}/lib/modules/3.10.73/$i" "${FILESYSTEM_MOD_DIR}/lib/modules/${FREETZ_KERNEL_VERSION_MODULES_SUBDIR}/$i"
done

echo2 "copying 7412 dect files"
file="lib/modules/dectfw_secondlevel_441.hex"
cp -a "${FILESYSTEM_TK_DIR}/$file" "${FILESYSTEM_MOD_DIR}/$file"

echo2 "copying 7412 webif files"
#dsl
[ "$FREETZ_AVM_VERSION_07_1X_MIN" == "y" ] && file="usr/www/avm/css/rd/illustrations/box.gif" || file="usr/www/avm/css/default/images/box.gif"
cp -a "${FILESYSTEM_TK_DIR}/usr/www/avm/css/default/images/box.gif" "${FILESYSTEM_MOD_DIR}/$file"
#dect
[ "$FREETZ_AVM_VERSION_07_1X_MIN" == "y" ] && file="usr/www/avm/css/rd/illustrations/illu_dectFbox.png" || file="usr/www/avm/css/default/images/dect_fbox_icon.png"
cp -a "${FILESYSTEM_TK_DIR}/usr/www/avm/css/default/images/dect_fbox_icon.png" "${FILESYSTEM_MOD_DIR}/$file"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW218 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW209

echo2 "patching rc.S and rc.conf"
modsed -r 's/(CONFIG_ETH_COUNT)=.*$/\1="1"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
#modsed -r 's/(CONFIG_DECT_HOME)=.*$/\1="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  #AHA?
#modsed -r 's/(CONFIG_HOME_AUTO)=.*$/\1="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  #AHA?
#modsed -r 's/(CONFIG_HOME_AUTO_NET)=.*$/\1="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  #AHA?
modsed -r 's/(CONFIG_INSTALL_TYPE)=.*$/\1="mips34_128MB_vdsl_1eth_1ab_wlan11n_56213"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed -r 's/(CONFIG_PRODUKT)=.*$/\1="Fritz_Box_HW209"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed -r 's/(CONFIG_PRODUKT_NAME)=.*$/\1="FRITZ!Box 7412"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed -r 's/(CONFIG_VERSION_MAJOR)=.*$/\1="137"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7430
echo2 "applying install patch"
modsed "s/mips34_128MB_vdsl_dect441_4eth_1usb_host_1ab_wlan11n_04371/mips34_128MB_vdsl_1eth_1ab_wlan11n_56213/g" "${FIRMWARE_MOD_DIR}/var/install"

