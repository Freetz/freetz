[ "$FREETZ_TYPE_EXTENDER" == "y" ] || return 0
[ "$FREETZ_AVM_VERSION_06_5X_MAX" == "y" ] || return 0
[ "$FREETZ_TYPE_0546" == "y" -a "$FREETZ_AVM_VERSION_06_5X" == "y" ] && return 0
[ "$FREETZ_TYPE_0300" == "y" ] && return 0
[ "$FREETZ_TYPE_1759" == "y" ] && return 0
echo1 "enabling network config"

# patcht Heimnetz > Netzwerk
modpatch \
  "$FILESYSTEM_MOD_DIR" \
  "${PATCHES_COND_DIR}/821-show_network_repeater/" \
  "${MENU_DATA_LUA}"

