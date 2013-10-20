# 7270_v2 firmware on 7270_v1 hardware
isFreetzType 7270_V1_V2 || return 0

echo1 "adapt firmware for 7270v1"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270_16 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270

# patch HWRevision detection to fix online help
modsed "s/HWRevision=.*$/HWRevision=139/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon WLAN 7270 v1\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_7270\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_ROM_SIZE=.*$/CONFIG_ROM_SIZE=\"8\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_05265\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7270 v2
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_61056/ur8_8MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_05265/g" "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/kernel_start=0x90020000/kernel_start=0x90010000/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/kernel_size=16121856/kernel_size=7798784/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/urlader_size=131072/urlader_size=65536/' "${FIRMWARE_MOD_DIR}/var/install"

[ "$FREETZ_REPLACE_KERNEL" == "y" ] && return 0

# Fix cpmac hardware revision from 139 (7270_v2) to 122 (7270_v1).
# This way we can avoid "replace kernel".
echo2 "patching kernel HWRevision"

echo2 "    step 1: unpack kernel"
addr=($(${TOOLS_DIR}/unpack-kernel ${RAW_KERNEL_MOD} ${RAW_KERNEL_MOD}.unp)) || exit 1

echo2 "    step 2: patch unpacked kernel"
# 0x3843B5
${TOOLS_DIR}/sfk replace ${RAW_KERNEL_MOD}.unp -binary "/687731333911EF617C68B3/687731323211EF617C68B3/" -yes >/dev/null 2>&1
# 0x38E57E
${TOOLS_DIR}/sfk replace ${RAW_KERNEL_MOD}.unp -binary "/687731333911ED617C68B3/687731323211ED617C68B3/" -yes >/dev/null 2>&1
# 0x398A25
${TOOLS_DIR}/sfk replace ${RAW_KERNEL_MOD}.unp -binary "/68773133391144617C68B3/68773132321144617C68B3/" -yes >/dev/null 2>&1
# 0x3E591D
${TOOLS_DIR}/sfk replace ${RAW_KERNEL_MOD}.unp -binary "/5F68773133390061766D5F/5F68773132320061766D5F/" -yes >/dev/null 2>&1
# 0x3FE28C
${TOOLS_DIR}/sfk replace ${RAW_KERNEL_MOD}.unp -binary "/58E64F948B000000/58E64F947A000000/" -yes >/dev/null 2>&1
# 0x3FED6F
${TOOLS_DIR}/sfk replace ${RAW_KERNEL_MOD}.unp -binary "/008B000000000000008D/007A000000000000008D/" -yes >/dev/null 2>&1
# 0x40FA4C
${TOOLS_DIR}/sfk replace ${RAW_KERNEL_MOD}.unp -binary "/3133392000000000/3132322000000000/" -yes >/dev/null 2>&1
[ $? -eq 1 ] || exit 1

echo2 "    step 3: re-pack kernel with LZMA"
${TOOLS_DIR}/lzma e -lc1 -lp2 -pb2 ${RAW_KERNEL_MOD}.unp ${RAW_KERNEL_MOD}.lzma 2>/dev/null || exit 1

echo2 "    step 4: convert packed kernel into format expected by EVA bootloader"
load=${addr[0]##*=}
entry=${addr[1]##*=}
${TOOLS_DIR}/lzma2eva $load $entry ${RAW_KERNEL_MOD}.lzma ${RAW_KERNEL_MOD}.eva

echo2 "    step 5: pad EVA kernel to multiple of 256 bytes"
dd if=${RAW_KERNEL_MOD}.eva of=${RAW_KERNEL_MOD} bs=256 conv=sync 2>/dev/null || exit 1
rm -f ${RAW_KERNEL_MOD}.*
echo2 "    done"
