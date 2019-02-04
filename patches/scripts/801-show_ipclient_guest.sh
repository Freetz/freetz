[ "$FREETZ_AVM_VERSION_06_0X_MIN" == "y" ] || return 0
[ "$FREETZ_TYPE_WLAN_REPEATER" != "y"  ] || return 0
echo1 "enabling ipclient guest"


# patcht WLAN > Gastzugang

# 06.05
#/usr/www/all/wlan/guest_access.lua
#opmode_eth_ipclient
#var disable_all = <?lua box.out(tostring((box.query("box:settings/opmode") == "opmode_eth_ipclient") and g_hide_rep_auto_update)) ?>;
#var disable_all = false; -- <?lua box.out(tostring((box.query("box:settings/opmode") == "opmode_eth_ipclient") and g_hide_rep_auto_update)) ?>;

enable_page() {
modsed \
  "s/show_page.*\/${1}.lua\"] =/& ${2:-true} ; dummy =/g" \
  "${HTML_LANG_MOD_DIR}/menus/menu_show.lua"
}
enable_page guest_access "wlan_on() and not is_wlan_ata()"

