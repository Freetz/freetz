[ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ] || return 0

[ -n "$SYSTEMD_CORE_MOD_DIR" ] && file="etc/boot.d/core/20-modload" || file="etc/init.d/S20-modload"
echo1 "adding /$file"

[ ! -e "${FILESYSTEM_MOD_DIR}/$file" ] && echo '#!/bin/sh' > "${FILESYSTEM_MOD_DIR}/$file"
echo '/usr/bin/modload 2>&1 | tee /var/log/mod_load.log' >> "${FILESYSTEM_MOD_DIR}/$file"
chmod +x "${FILESYSTEM_MOD_DIR}/$file"

