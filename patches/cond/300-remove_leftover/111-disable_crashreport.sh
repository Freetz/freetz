[ -e "${FILESYSTEM_MOD_DIR}/etc/onlinechanged/send_crashreport" ] || return 0
echo1 "disabling crashreport"

rm_files "${FILESYSTEM_MOD_DIR}/etc/onlinechanged/send_crashreport"

