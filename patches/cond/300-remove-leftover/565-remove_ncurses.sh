[ -e "${FILESYSTEM_MOD_DIR}/usr/bin/ncurses5-config" ] || return 0
echo1 "removing ncurses"

rm_files "${FILESYSTEM_MOD_DIR}/usr/bin/ncurses5-config"

