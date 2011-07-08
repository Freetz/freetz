cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/etc/init.d/S20-modload"
/usr/bin/modload 2>&1 | tee /var/log/mod_load.log

EOF
