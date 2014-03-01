echo1 "applying /dev/led patch"

for f in /bin/update_led_on /bin/update_led_off; do
	[ -f "${FILESYSTEM_MOD_DIR}${f}" ] && modsed 's,/var/led,/dev/led,g' "${FILESYSTEM_MOD_DIR}${f}"
done
