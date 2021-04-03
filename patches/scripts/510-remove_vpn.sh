[ "$FREETZ_REMOVE_AVM_VPN" == "y" ] || return 0
echo1 "removing AVM-VPN files"

for files in \
  bin/avmike \
  $(isNeededEntry "libikeapi" "${FILESYSTEM_MOD_DIR}/usr/bin/ctlmgr" "${FILESYSTEM_MOD_DIR}/usr/bin/avm/ctlmgr" || echo 'lib/libikeapi*.so*') \
  lib/libikecrypto*.so* \
  lib/libikeossl*.so* \
  usr/share/ctlmgr/libvpnstat.so \
  usr/www/all/internet/vpn.lua \
  $(find ${FILESYSTEM_MOD_DIR} -iwholename "*usr/www/*/html/*vpn*" -printf "%P\n") \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

echo1 "patching WebUI"
for files in $(grep -rsl '<? setvariable var:showVpn 1 ?>' ${HTML_SPEC_MOD_DIR}); do
	echo2 "patching $files"
	modsed 's/<? setvariable var:showVpn 1 ?>//' "$files"
done

# patcht System > FRITZ!Box-Benutzer > edit > Berechtigungen > VPN
file="${HTML_LANG_MOD_DIR}/system/boxuser_edit.lua"
if [ -e "$file" ]; then
	echo2 "patching $file"
	modsed \
	  's/.*function rights_checkbox(.*)/&\nif which == "vpn_access" then return html.div{} end/' \
	  "$file" \
	  "then return html.div{} end"
fi

echo1 "patching rc.conf"
modsed "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

