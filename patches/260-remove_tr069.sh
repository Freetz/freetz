[ "$FREETZ_REMOVE_TR069" == "y" ] || return 0

echo1 "removing tr069 stuff"
rm_files "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr064.so"
	 "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so" \
	 "${FILESYSTEM_MOD_DIR}/bin/tr069starter" \
	 "${FILESYSTEM_MOD_DIR}/sbin/tr069discover" \
	 "${FILESYSTEM_MOD_DIR}/usr/bin/tr069fwupdate"

echo1 "patching default tr069.cfg"
find ${FILESYSTEM_MOD_DIR}/etc -name tr069.cfg -exec sed -e 's/enabled = yes/enabled = no/' -i '{}' \;

if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" ]; then
	echo1 "patching /etc/init.d/rc.conf"
	sed -i -e "s/CONFIG_TR069=.*$/CONFIG_TR069=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	sed -i -e "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi