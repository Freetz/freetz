[ "$FREETZ_ENABLE_LED_DEACTIVATION" == "y" ] || return 0
echo1 "re-adding LED (de-)activation page"

if [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ] ; then
	PVER="07_0X"
elif [ "$FREETZ_AVM_VERSION_06_9X_MIN" == "y" ] ; then
	PVER="06_9X"
elif [ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ] ; then
	PVER="06_8X"
elif [ "$FREETZ_AVM_VERSION_06_5X_MIN" == "y" ] ; then
	PVER="06_5X"
elif [ "$FREETZ_AVM_VERSION_06_0X_MIN" == "y" ] ; then
	PVER="06_0X"
fi

modpatch "${FILESYSTEM_MOD_DIR}" "${PATCHES_COND_DIR}/535-enable_led_deactivation/535-enable_led_deactivation-${PVER}.patch"

