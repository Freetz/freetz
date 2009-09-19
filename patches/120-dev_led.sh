echo1 "applying /dev/led patch"

[ -f "${FILESYSTEM_MOD_DIR}/bin/update_led_on" ] && modsed 's/\/var\/led/\/dev\/led/' "${FILESYSTEM_MOD_DIR}/bin/update_led_on"
[ -f "${FILESYSTEM_MOD_DIR}/bin/update_led_off" ] && modsed 's/\/var\/led/\/dev\/led/' "${FILESYSTEM_MOD_DIR}/bin/update_led_off"
