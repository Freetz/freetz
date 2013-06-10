[ "$FREETZ_REMOVE_WLAN" == "y" ] || return 0

echo1 "removing WLAN files"
rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name '*wireless*')
rm_files $(find ${FILESYSTEM_MOD_DIR} ! -name '*.cfg' -a -name '*wlan*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(dev|oldroot|proc|sys|var)/')
rm_files \
  ${FILESYSTEM_MOD_DIR}/lib/modules/fw_dcrhp_1150_ap.bin \
  ${FILESYSTEM_MOD_DIR}/sbin/hostapd \
  ${FILESYSTEM_MOD_DIR}/sbin/wstart \
  ${FILESYSTEM_MOD_DIR}/sbin/wpa_supplicant \
  ${FILESYSTEM_MOD_DIR}/usr/bin/wpa_authenticator \
  ${FILESYSTEM_MOD_DIR}/sbin/avmstickandsurf \
  ${FILESYSTEM_MOD_DIR}/usr/bin/iwpriv \
  ${FILESYSTEM_MOD_DIR}/usr/bin/iwconfig \
  ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libwlan.so \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-avmwlan-usb

menu2html_remove wlan

# patcht Heimnetz > Netzwerk > IPv4-Einstellungen
sedfile="${HTML_LANG_MOD_DIR}/net/boxnet.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed 's/config.WLAN/0/g' $sedfile
fi

# patcht Internet > Zugangsdaten > Internetzugang
sedfile="${HTML_LANG_MOD_DIR}/internet/internet_settings.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed '/^require"wlanscan"$/d' $sedfile
	modsed '/^wlanscanOnload.*$/d' $sedfile
fi

# patcht Heimnetz > Netzwerk > Geraete und Benutzer
sedfile="${HTML_LANG_MOD_DIR}/net/network_user_devices.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed 's/&& <?lua box.js(tostring(g_dev.wlan_count<2)) ?>//g' $sedfile
fi

# fix AVM-VPN: Set WLAN to "disabled" value "0". Otherwise ctlmgr_ctl reports "no emu" or "" (nothing).
for sedfile in $(grep -R -l  "wlan:settings/ap_enabled" ${HTML_LANG_MOD_DIR}/* 2>/dev/null); do
	echo1 "patching ${sedfile##*/}"
	modsed 's#box.query("wlan:settings/ap_enabled[^"]*")#"0"#g ; s#<? query wlan:settings/ap_enabled[^ ]* ?>#0#g ; s#{ sz_query = "wlan:settings/ap_enabled"}#{ sz_value = "0" }#g' $sedfile
done

echo1 "patching rc.conf"
modsed "s/CONFIG_WLAN=.*$/CONFIG_WLAN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

