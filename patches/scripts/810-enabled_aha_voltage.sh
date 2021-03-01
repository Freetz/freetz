[ -e "${FILESYSTEM_MOD_DIR}/usr/www/all/webservices/homeautoswitch.lua" -a "$FREETZ_AVM_VERSION_06_2X_MIN" == "y" ] || return 0
echo1 "enabling aha voltage"

# patcht homeautoswitch.lua > getdevicelistinfos"

if [ "$FREETZ_AVM_VERSION_07_2X_MIN" == "y" ] ; then
	PVER="07_2X"
elif [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] ; then
	PVER="07_0X"
else
	PVER="06_XX"
fi

modpatch \
  "$FILESYSTEM_MOD_DIR" \
  "${PATCHES_COND_DIR}/enabled_aha_voltage_${PVER}.patch"

