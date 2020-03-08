[ -n "$SYSTEMD_CORE_MOD_DIR" ] || return 0

echo1 "adding modload.service"
cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/lib/systemd/system/modload.service"
[Unit]
ExecStart=/etc/boot.d/core/20-modload
Type=oneshot
DefaultDependencies=no
After=tffs.service environment.service
[Install]
WantedBy=environment.target
EOF

echo1 "adding rcmod.service"
cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/lib/systemd/system/rcmod.service"
[Unit]
ExecStart=/etc/boot.d/core/99-zzz-rcmod
Type=oneshot
DefaultDependencies=no
After=net.service modload.service
[Install]
WantedBy=multi-user.target
EOF

