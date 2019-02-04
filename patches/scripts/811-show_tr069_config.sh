[ -f "${HTML_LANG_MOD_DIR}/internet/providerservices.lua" ] || return 0
echo1 "enabling tr069 config"

# iDea: PeterPawn (http://www.ip-phone-forum.de/showthread.php?t=278548)


# patcht Internet > Zugangsdaten > Andere-Dienste (Seitendaten)

always_true() {
modsed -r \
  "s/^(${1} = ).*/\1true/g" \
  "${HTML_LANG_MOD_DIR}/internet/providerservices.lua"
}
always_true show
always_true show_disabled


# patcht Internet > Zugangsdaten > Andere-Dienste (Menupunkt)

enable_page() {
modsed \
  "s/${1}.lua\"] =/& true ; dummy =/g" \
  "${HTML_LANG_MOD_DIR}/menus/menu_show.lua"
}
enable_page providerservices
	
