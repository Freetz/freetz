[ "$FREETZ_REMOVE_RUNCLOCK" = "y" ] || return 0;

echo1 "removing run_clock"

rm_files \
  "${FILESYSTEM_MOD_DIR}/lib/systemd/system/run_clock.service"

cat > "${FILESYSTEM_MOD_DIR}/bin/run_clock" << EOF
#!/bin/sh
:
EOF

