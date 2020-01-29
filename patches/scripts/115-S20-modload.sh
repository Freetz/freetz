[ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ] || return 0

[ -e "${FILESYSTEM_MOD_DIR}/etc/boot.d/core/99-tail" ] && file="etc/boot.d/core/20-modload" || file="etc/init.d/S20-modload"
echo1 "adding /$file"

echo '/usr/bin/modload 2>&1 | tee /var/log/mod_load.log' > "${FILESYSTEM_MOD_DIR}/$file"
chmod +x "${FILESYSTEM_MOD_DIR}/$file"

