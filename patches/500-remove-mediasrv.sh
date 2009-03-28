[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0
echo1 "remove medissrv files"
rm_files "${FILESYSTEM_MOD_DIR}/sbin/mediasrv" \
	 "${FILESYSTEM_MOD_DIR}/sbin/start_mediasrv" \
	 "${FILESYSTEM_MOD_DIR}/sbin/stop_mediasrv"

echo1 "patching rc.conf"
sed -i -e "s/CONFIG_MEDIASRV=.*$/CONFIG_MEDIASRV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
