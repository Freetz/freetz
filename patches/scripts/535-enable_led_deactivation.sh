[ "$FREETZ_ENABLE_LED_DEACTIVATION" == "y" -a -f "${FILESYSTEM_MOD_DIR}/usr/www/all/system/led_display.lua" ] || return 0

echo1 "re-adding LED (de-)activation page"
modpatch "${FILESYSTEM_MOD_DIR}" "${PATCHES_COND_DIR}/enable_led_deactivation-${FREETZ_TYPE_PREFIX_SERIES_SUBDIR}.patch"
