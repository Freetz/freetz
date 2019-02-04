[ "$FREETZ_AVMPLUGINS_INTEGRATE" == "y" ] || return 0
[ "$FREETZ_AVM_HAS_PLUGIN_TAM" != "y" ] && return 0
[ "$FREETZ_AVMPLUGINS_TAM" == "y" ] && return 0
echo1 "hiding TAM plugin"


# patcht Telefonie > Anrufbeantworter
modsed \
  's/pageData\["tam"\] /&and nil /g' \
  "${HTML_LANG_MOD_DIR}/menus/menu_data.lua"
	
# patcht Übersicht > Anrufbeantworter
modsed \
  '/, create_Tam(/d' \
  "${HTML_LANG_MOD_DIR}/home/home.js"

