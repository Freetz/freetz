[ -f "${HTML_LANG_MOD_DIR}/system/update_auto.lua" ] || return 0
echo1 "enabling update config"

# iDea:  hermann72pb (http://www.ip-phone-forum.de/showthread.php?t=280142)


# patcht System > Update > Auto-Update (Menupunkt)

enable_page() {
modsed \
  "s/${1}.lua\"] =/& true ; dummy =/g" \
  "${HTML_LANG_MOD_DIR}/menus/menu_show.lua"
}
enable_page update_auto

