[ "$FREETZ_TYPE_FON_WLAN_7240" == "y" -o "$FREETZ_TYPE_FON_WLAN_7270" == "y" ] || return 0

echo1 "adding volume counter"
if [ "$FREETZ_TYPE_LABOR_DSL" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/470-volumecounter_7270_labor_dsl.patch"
elif [ "$FREETZ_TYPE_LABOR_PHONE" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/470-volumecounter_7270_labor_phone.patch"
elif [ "$FREETZ_TYPE_LABOR_AIO" == "y" ]; then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/470-volumecounter_7270_labor_aio.patch"
else
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/470-volumecounter_7270.patch"
fi

sed -i -e "s/CONFIG_VOL_COUNTER=\"n\"/CONFIG_VOL_COUNTER=\"y\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
