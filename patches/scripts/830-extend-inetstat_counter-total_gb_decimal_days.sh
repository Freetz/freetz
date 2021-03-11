[ "$FREETZ_MODIFY_COUNTER" == "y" ] || return 0
echo1 "patching online counter"

if [ "$FREETZ_AVM_VERSION_07_25_MIN" == "y" ] ; then
	PVER="07_25"
elif [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] ; then
	PVER="07_0X"
elif [ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ] ; then
	PVER="06_8X"
elif [ "$FREETZ_AVM_VERSION_06_5X_MIN" == "y" ] ; then
	PVER="06_5X"
fi

modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/830-extend-inetstat_counter-total_gb_decimal_days/830-extend-inetstat_counter-total_gb_decimal_days_${PVER}.patch"

