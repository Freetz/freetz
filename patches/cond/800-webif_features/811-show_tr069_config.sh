[ -f "${HTML_LANG_MOD_DIR}/internet/providerservices.lua" ] || return 0
echo1 "enabling tr069 config"

# iDea: PeterPawn (http://www.ip-phone-forum.de/showthread.php?t=278548)


# patcht Internet > Zugangsdaten > Andere-Dienste (Seitendaten)
always_value() {
	modsed -r \
	  "s/^(${1} = ).*/\1$2/g" \
	  "${HTML_LANG_MOD_DIR}/internet/providerservices.lua"
}
always_value "show" "true"
always_value "show_disabled" "false"

# patcht Internet > Zugangsdaten > Andere-Dienste (Menupunkt)
enable_page providerservices

