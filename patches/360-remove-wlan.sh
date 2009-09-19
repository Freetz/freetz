[ "$FREETZ_REMOVE_WLAN" == "y" ] || return 0

echo1 "removing WLAN files"
rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name '*wireless*')
rm_files $(find ${FILESYSTEM_MOD_DIR} ! -name '*.cfg' -a -name '*wlan*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(dev|oldroot|proc|sys|var)/')
rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/fw_dcrhp_1150_ap.bin \
	${FILESYSTEM_MOD_DIR}/usr/bin/wpa_authenticator

echo1 "patching rc.conf"
modsed "s/CONFIG_WLAN=.*$/CONFIG_WLAN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
