[ "$FREETZ_REMOVE_AVM_WIREGUARD" == "y" ] || return 0
echo1 "removing WireGuard files"

for files in \
  bin/vpnd \
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

supervisor_delete_service "vpnd"

#WebUI is patched by selected remove-vpn

