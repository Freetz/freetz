[ "$FREETZ_PATCH_GUEST" == "y" ] || return 0
echo1 "enabling ipclient guest"

# patcht WLAN > Gastzugang
enable_page_advanced() {
	modsed \
	  "s/show_page.*\/${1}.lua\"] =/& ${2:-true} ; dummy =/g" \
	  "${HTML_LANG_MOD_DIR}/menus/menu_show.lua"
}
enable_page_advanced guest_access "wlan_on() and not is_wlan_ata()"

# 06.05
file="$HTML_LANG_MOD_DIR/wlan/guest_access.lua"
if [ -e "$file" ]; then
	#var disable_all = <?lua box.out(tostring((box.query("box:settings/opmode") == "opmode_eth_ipclient") and g_hide_rep_auto_update)) ?>;
	modsed \
	  "s/opmode_eth_ipclient/opmode_eth_ipclient_freetz/g" \
	  "$file"
fi
#To make the greyed out LAN4 item on the page become accessible
file="$HTML_LANG_MOD_DIR/net/network_settings.lua"
if [ -e "$file" ]; then
	modsed \
	  "s/bGuestDisabled = true/bGuestDisabled = false/g" \
	  "$file"
fi

