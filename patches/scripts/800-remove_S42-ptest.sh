[ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/S42-ptest" ] || return 0

# iDea:  Hippie2000

echo1 "removing 'S42-ptest'"
rm_files \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S42-ptest"

