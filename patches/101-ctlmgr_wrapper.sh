[ "$FREETZ_LIB_libfreetz" == "y" ] || return 0

mv "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr" "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr.bin"
cat << 'EOF' >> "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr"
#!/bin/sh
export LD_PRELOAD=libfreetz.so.1.0.0
CTLMGR_BINARY="/usr/bin/ctlmgr.bin"
exec $CTLMGR_BINARY "$@"
EOF

chmod 755 "$FILESYSTEM_MOD_DIR/usr/bin/ctlmgr"
