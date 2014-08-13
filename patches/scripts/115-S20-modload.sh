[ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ] || return 0

echo1 "adding /etc/init.d/S20-modload"

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/init.d/S20-modload"
/usr/bin/modload 2>&1 | tee /var/log/mod_load.log

EOF
