[ "$FREETZ_REMOVE_PUBKEY" == "y" ] || return 0
echo1 "removing avm_firmware_public_key1"
rm_files ${FILESYSTEM_MOD_DIR}/etc/avm_firmware_public_key1

#[ -e "${FILESYSTEM_MOD_DIR}/etc/avm_firmware_public_key4" ] || return 0
#echo1 "removing avm_firmware_public_key4"
#rm_files ${FILESYSTEM_MOD_DIR}/etc/avm_firmware_public_key4

