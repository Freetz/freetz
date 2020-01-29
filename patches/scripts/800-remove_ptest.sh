
echo1 "removing ptest"
rm_files \
  "${FILESYSTEM_MOD_DIR}/lib/systemd/system/ptest_release.service" \
  "${FILESYSTEM_MOD_DIR}/lib/systemd/system/ptest.service" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.ptest.release" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S42-ptest" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S46-ptest" \
  "${FILESYSTEM_MOD_DIR}/etc/boot.d/ptest"

