[ "$FREETZ_TYPE_EXTENDER" == "y" ] || return 0
[ "$FREETZ_AVM_VERSION_06_2X_MAX" != "y" -a "$FREETZ_TYPE_0546" != "y" ] && return 0
echo1 "enabling network config"


# patcht Heimnetz > Netzwerk

modpatch \
  "$FILESYSTEM_MOD_DIR" \
  "${PATCHES_COND_DIR}/show_network_repeater/" \
  "/usr/www/all/menus/menu_data.lua"

