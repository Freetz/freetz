[ "$FREETZ_REMOVE_NAS" == "y" ] || return 0

echo1 "removing nas"
rm -rf "${FILESYSTEM_MOD_DIR}/usr/www.nas"
ln -sf www "${FILESYSTEM_MOD_DIR}/usr/www.nas"

modsed "s/CONFIG_NAS.*/CONFIG_NAS=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
# 7240, 7270 and 7390 Labor Preview have "if (config.NAS) in menu_page_head.html
# so there is no need to patch
if isFreetzType 3270 3270_V3 7320 7340 || (isFreetzType 7390 && ! isFreetzType LABOR_PREVIEW); then
	modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_DIR}/cond/de/remove_nas_7270.patch"
fi

echo2 "removing internal memory"
rm -rf ${FILESYSTEM_MOD_DIR}/etc/internal_memory_default*.tar
