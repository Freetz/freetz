# 7270-05 firmware on 7570 hardware
isFreetzType 7570_7270 || return 0
[ -z "$FIRMWARE2" ] && error 1 "no tk firmware"

echo1 "adapt firmware for 7570 as alien"
# 7270v2 has modules:	c55fw.hex dectfw_firstlevel.hex dectfw_secondlevel.hex microvoip_isdn_top.bit pm_info.in wlan_eeprom_hw0.bin
# 7570 has modules:	bitfile.bit c55fw.hex dectfw_firstlevel.hex dectfw_secondlevel.hex pm_info.in vinax_fw_adsl_A.bin vinax_fw_adsl_B.bin vinax_fw_vdsl.bin wlan_eeprom_hw0.bin

echo2 "copying 7570 piglet modules"
cp -a "${DIR}/.tk/original/filesystem/lib/modules/bitfile.bit" "${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit"

echo2 "Remove obsolete 7270 DSL (ur8-)modules"
rm -rf "${FILESYSTEM_MOD_DIR}/lib/modules/dsp_ur8"

# DECT-Anlage braucht den 96 MHz Takt NICHT (250E): 'piglet_use_pll3_clk=1' entfällt, da fpga den 96 MHz Takt aus dem DECT Takt selbst erzeugt.
# patch loading of bitfile
echo2 "patching S11-piglet"
modsed  "/^modprobe Piglet_noemif/ {s#piglet_dectmode=0x100 ## ; s#piglet_use_pll3_clk=1##}" "${FILESYSTEM_MOD_DIR}/etc/init.d/S11-piglet"

echo2 "copying 7570 webif files"
files="css/default/images/kopfbalken_mitte.gif"
if [ "$FREETZ_AVM_VERSION_05_5X_MAX" == "y" ]; then
files+=" html/de/images/kopfbalken.gif"
files+=" html/de/images/DectFBoxIcon.png"
fi
for i in $files; do
	cp -a "${DIR}/.tk/original/filesystem/usr/www/avme/$i" "${FILESYSTEM_MOD_DIR}/usr/www/all/$i"
done

# To be sure, just force existence of at least avm and avme
echo2 "creating and avm(e) web symlinks"
ln -s all "${FILESYSTEM_MOD_DIR}/usr/www/avme" 2>/dev/null
ln -s all "${FILESYSTEM_MOD_DIR}/usr/www/avm" 2>/dev/null

echo2 "moving default config dir, creating default symlinks for avm and avme"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270_16 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570
if isFreetzType LANG_DE; then
ln -s avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570/avme" 2>/dev/null
else
ln -s avme "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7570/avm" 2>/dev/null
fi

echo2 "patching rc.conf"
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7570 vDSL\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7570\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_13589\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"75\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7270v2
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_61056/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_multiannex_13589/g" "${FIRMWARE_MOD_DIR}/var/install"
# force accept on 7570, Speedport W920V and 7570_HN
# patch install script to accept firmware from 7570 or 7270v2
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_[a-z_0-9]*/ur8_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_mimo_usb_host_dect_40456/g" "${FIRMWARE_MOD_DIR}/var/install"
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
modsed "/testing acceptance for device .* \.\.\./,/testing acceptance for device .* done/ d; /\$DISABLE_/a\ ${SEDSTRING}" "${FIRMWARE_MOD_DIR}/var/install"
