isFreetzType 7412_7430 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7412"

files="lib/modules/dectfw_secondlevel_441.hex"
#files="\
#  lib/modules/dectfw_secondlevel_441.hex \
#  lib/modules/3.10.73/net/aae.ko"
for i in $files; do
	cp -a "${FILESYSTEM_TK_DIR}/$i" "${FILESYSTEM_MOD_DIR}/$i"
done

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW218 \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW209

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

