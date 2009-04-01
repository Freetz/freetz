[ "$FREETZ_TYPE_FON_WLAN_7270_16MB" == "y" -a "$FREETZ_TYPE_LANG_DE" == "y" ] || return 0

echo1 "applying 16MB patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/${FREETZ_TYPE_STRING}_16MB_flash.patch"

