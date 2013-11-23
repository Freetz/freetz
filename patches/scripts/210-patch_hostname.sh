[ "$FREETZ_AVM_HAS_ONLY_HTML" != "y" ] || return 0
echo1 "patching hostname to allow dots/domain name"

# patch Heimnetz > FRITZ!Box-Name
# fbname={pat=[[^[a-zA-Z0-9%-]*$]],reg=[[/^[a-z0-9\-]*$/i]]},
# char_range_regex(uiViewName/box_name, fbname, error_txt)
modsed \
  's#^fbname=.*#fbname={pat=[[^[a-zA-Z0-9%-%.]*$]],reg=[[/^[a-z0-9\\-\\.]*$/i]]},#' \
  "${LUA_MOD_DIR}/val.lua"

