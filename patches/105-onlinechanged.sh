
echo1 "patching /bin/onlinechanged"

rm -f "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"

# run in background, multid terminates the script
cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
#!/bin/sh
/bin/onlinechanged.sh "$@" &
EOF

chmod +x "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
