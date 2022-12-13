[ -n "$SYSTEMD_CORE_MOD_DIR" ] || return 0
echo1 "adding supervisor services"

echo2 "adding modload.service"
cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/lib/systemd/system/modload.service"
[Unit]
ExecStart=/etc/boot.d/core/20-modload
Type=oneshot
DefaultDependencies=no
After=tffs.service environment.service
[Install]
WantedBy=environment.target
EOF

after_service=''
for service in multid rextd net_basic net; do
[ -e "${FILESYSTEM_MOD_DIR}/lib/systemd/system/${service}.service" ] && after_service="${service}.service ${after_service}"  # && break
done
[ -z "${after_service}" ] && warn "Could not find any usable service file!"

echo2 "adding zzz-rcmod.service"
cat << EOF > "${FILESYSTEM_MOD_DIR}/lib/systemd/system/zzz-rcmod.service"
[Unit]
ExecStart=/etc/boot.d/core/99-zzz-rcmod
Type=oneshot
DefaultDependencies=no
After=${after_service}modload.service
[Install]
WantedBy=multi-user.target
EOF

