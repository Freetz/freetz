[ -e "${FILESYSTEM_MOD_DIR}/lib/systemd/system/inetd.service" ] || return 0

echo1 "removing inetd.service"
rm_files \
  "${FILESYSTEM_MOD_DIR}/lib/systemd/system/inetd.service"

