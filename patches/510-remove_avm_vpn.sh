[ "$FREETZ_REMOVE_AVM_VPN" == "y" ] || return 0
echo1 "removing AVM-VPN files"
for files in \
 	bin/avmike \
	usr/share/ctlmgr/libvpnstat.so \
	; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

echo1 "patching rc.conf"
sed -i -e "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
