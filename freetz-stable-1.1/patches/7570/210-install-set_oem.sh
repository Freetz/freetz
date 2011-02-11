# patch install script to let either W920 and 7570 accept this FW
echo2 "applying install patch"
# set OEM to avme for international firmware
if ! isFreetzType LANG_DE; then
	modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/install-7570_W920V.patch" || exit 2
fi