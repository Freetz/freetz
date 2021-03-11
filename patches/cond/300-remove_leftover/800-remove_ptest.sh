
echo1 "removing ptest"

rm_files \
  "${FILESYSTEM_MOD_DIR}/usr/bin/ptest-waitForNetwork.sh" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.ptest.release" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S42-ptest" \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S46-ptest" \
  "${FILESYSTEM_MOD_DIR}/etc/boot.d/ptest"
supervisor_delete_service "ptest_release"
supervisor_delete_service "ptest"

