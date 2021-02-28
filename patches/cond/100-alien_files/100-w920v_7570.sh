# 7570 or 7270v2 firmware on W920V hardware (both defines FREETZ_TYPE_W920V_7570)
isFreetzType W920V_7570 || return 0

echo2 "creating tcom web symlink"
ln -s all "${FILESYSTEM_MOD_DIR}/usr/www/tcom" 2>/dev/null

echo2 "moving default config dir, creating default symlinks"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W920V
if isFreetzType LANG_DE; then
ln -s avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W920V/tcom" 2>/dev/null
else
ln -s avme "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_DECT_W920V/tcom" 2>/dev/null
fi

echo2 "patching rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon Speedport W 920V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_DECT_W920V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_40456\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"65\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

if [ "$FREETZ_PATCH_W920V_LED_MODULE" == "y" -a -n "$FIRMWARE2" ]; then
	# this is only enabled for fw 04.xx, no module for kernel 2.6.32
	echo1 "changing LED semantics to W920V"
	cp -a "${DIR}/.tk/original/filesystem/lib/modules/2.6.19.2/kernel/drivers/char/led_module.ko" "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.19.2/kernel/drivers/char/led_module.ko"
fi

# if not allready patched by "7270 to 7570", there is still the original "testing acceptance for device"
# and we need a patch to accept firmware despite of OEM just by matching HWRevision
SEDSTRING='   # just check for HWRewision of 7570, Speedport W920V or 7570_HN\
    hwrev="$(IFS="$IFS."; set $(grep HWRevision /proc/sys/urlader/environment); echo $2)"\
    case "$hwrev" in\
      135 | 146 | 153 )\
         korrekt_version=1\
         ;;\
      * )\
         korrekt_version=0\
         echo "HWRevision $hwrev not supported"\
         exit $INSTALL_WRONG_HARDWARE ;;\
    esac\
'
modsed "/testing acceptance for device .* done/a\ ${SEDSTRING}" "${FIRMWARE_MOD_DIR}/var/install"
modsed "/testing acceptance for device .* \.\.\./,/testing acceptance for device .* done/ d" "${FIRMWARE_MOD_DIR}/var/install"
