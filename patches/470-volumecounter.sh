[ "$FREETZ_TYPE_FON_WLAN_7270" == "y" ] && \
	[ "$FREETZ_TYPE_LABOR_IPV6" == "y" -o "$FREETZ_TYPE_LABOR_DSL" == "y" ] || return 0

echo1 "adding volume counter"
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/470-volumecounter_${FREETZ_TYPE_STRING}.patch"

sed -i -e "s/CONFIG_VOL_COUNTER=\"n\"/CONFIG_VOL_COUNTER=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
