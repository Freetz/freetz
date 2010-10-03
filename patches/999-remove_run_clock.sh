[ "$FREETZ_REMOVE_RUNCLOCK" = "y" ] || return 0;

echo1 "removing run_clock"
cat > "${FILESYSTEM_MOD_DIR}/bin/run_clock" << EOF
#!/bin/sh
:
EOF
