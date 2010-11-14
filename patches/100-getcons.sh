# Setconsole does the same. So delete getcons.
echo1 "removing /bin/getcons"
rm_files "${FILESYSTEM_MOD_DIR}/bin/getcons"

if [ "$FREETZ_PATCH_GETCONS" == "y" ]; then
cat >> ${FILESYSTEM_MOD_DIR}/etc/profile << EOF

setconsole
echo "Console Ausgaben auf dieses Terminal umgelenkt."
EOF
fi
