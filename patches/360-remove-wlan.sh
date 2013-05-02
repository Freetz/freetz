[ "$FREETZ_REMOVE_WLAN" == "y" ] || return 0

echo1 "removing WLAN files"
rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name '*wireless*')
rm_files $(find ${FILESYSTEM_MOD_DIR} ! -name '*.cfg' -a -name '*wlan*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(dev|oldroot|proc|sys|var)/')
rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/fw_dcrhp_1150_ap.bin \
	${FILESYSTEM_MOD_DIR}/sbin/wstart \
	${FILESYSTEM_MOD_DIR}/sbin/wpa_supplicant \
	${FILESYSTEM_MOD_DIR}/usr/bin/wpa_authenticator \
	${FILESYSTEM_MOD_DIR}/sbin/avmstickandsurf

for sedfile in $(grep -R -l  "wlan:settings/ap_enabled" ${HTML_LANG_MOD_DIR}/* 2>/dev/null); do
	# fix AVM-VPN: Set WLAN to "disabled" value "0". Otherwise ctlmgr_ctl reports "no emu" or "" (nothing).
	echo1 "patching ${sedfile##*/}"
	modsed 's#box.query("wlan:settings/ap_enabled[^"]*")#"0"#g ; s#<? query wlan:settings/ap_enabled[^ ]* ?>#0#g ; s#{ sz_query = "wlan:settings/ap_enabled"}#{ sz_value = "0" }#g' $sedfile
done

echo1 "patching rc.conf"
modsed "s/CONFIG_WLAN=.*$/CONFIG_WLAN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
