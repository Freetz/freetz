# 7570 firmware on Alice IAD 7570 hardware (should also work with 7570-ized 7270v2 firmware)
isFreetzType 7570_IAD || return 0

echo1 "adapt firmware for 7570 IAD"

echo2 "creating hansenet web symlinks"
ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/hansenet"

echo2 "moving default config dir, creating default symlink"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570_HN
if isFreetzType LANG_DE; then
ln -s avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570_HN/hansenet" 2>/dev/null
else
ln -s avme "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570_HN/hansenet" 2>/dev/null
fi

echo2 "patching rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"Alice IAD 7570 vDSL\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7570_HN\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_hansenet_60170\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"75\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

echo2 "applying install patch kernel_start and urlader_size"
modsed 's/kernel_start=0x90020000/kernel_start=0x90040000/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/urlader_size=131072/urlader_size=262144/' "${FIRMWARE_MOD_DIR}/var/install"

if [ "$FREETZ_REPLACE_KERNEL" == "y" ]; then
	SEDSTRING='\
found=$(grep -c -e "mtd[15].*0x90040000,0x907E0000" -e "mtd[15].*0x907E0000,0x90F80000" /proc/sys/urlader/environment) \
[ 2 -eq $found ] || korrekt_version=0 \
'
	# set mtd1 to 16 MB (244 * 64KB)
	modsed 's/kernel_size=16121856/kernel_size=15990784/' "${FIRMWARE_MOD_DIR}/var/install"
	modsed "/flash_start=/ a\ ${SEDSTRING}" "${FIRMWARE_MOD_DIR}/var/install"
	SEDSTRING='\
	### 7570_HN: set mtd1 to max size and unset mtd5 \
	echo mtd1 0x90040000,0x90F80000 > /proc/sys/urlader/environment \
	echo mtd5 > /proc/sys/urlader/environment \
	### \
	'
	modsed "/kernel.image to start(\$kernel_update_start)/ i\ ${SEDSTRING}" "${FIRMWARE_MOD_DIR}/var/install"
else
echo2 "set mtd1 to 8 MB"
	# use only 8 MB (122 * 64 KB)
	modsed 's/kernel_size=16121856/kernel_size=7995392/' "${FIRMWARE_MOD_DIR}/var/install"
fi

# patch install script to accept firmware from 7570 or 7270v2
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_[a-z_0-9]*/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_hansenet_60170/g" "${FIRMWARE_MOD_DIR}/var/install"

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
