[ -e "${FILESYSTEM_MOD_DIR}/usr/www/all/webservices/homeautoswitch.lua" -a "$FREETZ_AVM_VERSION_06_2X_MIN" == "y" ] || return 0
echo1 "enabling aha voltage"


# patcht homeautoswitch.lua > getdevicelistinfos"

[ "$FREETZ_AVM_VERSION_07_0X_MIN" != "y" ] && mod_patch='enabled_aha_voltage.FOS6.patch' || mod_patch='enabled_aha_voltage.FOS7.patch'

modpatch \
  "$FILESYSTEM_MOD_DIR" \
  "${PATCHES_COND_DIR}/${mod_patch}"

