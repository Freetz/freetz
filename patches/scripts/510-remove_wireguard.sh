[ "$FREETZ_REMOVE_AVM_WIREGUARD" == "y" ] || return 0
echo1 "removing WireGuard files"

for files in \
  bin/wg \
  bin/wg-addmaster \
  bin/wg-addslave \
  bin/wg-init \
  bin/wg-removepeer \
  bin/wg-utils \
  lib/libwireguard.so \
  ${MODULES_DIR}/extra/wireguard.ko \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

#echo1 "patching WebUI"
# no device to test

#echo1 "patching rc.conf"
# not used (yet?) - or replaces avm's ipv4-only vpn and uses CONFIG_VPN ?
#modsed "s/CONFIG_WG=.*$/CONFIG_WG=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

