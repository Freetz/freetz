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

after=''
for unit in multid.service rextd.service network.target net_basic.service net.service; do
[ -e "${FILESYSTEM_MOD_DIR}/lib/systemd/system/${unit}" ] && after="${unit} ${after}"  # && break
done
[ -z "${after}" ] && warn "Could not find any usable unit file!"

echo2 "adding zzz-rcmod.service"
cat << EOF > "${FILESYSTEM_MOD_DIR}/lib/systemd/system/zzz-rcmod.service"
[Unit]
ExecStart=/etc/boot.d/core/99-zzz-rcmod
Type=oneshot
DefaultDependencies=no
After=${after}modload.service
[Install]
WantedBy=multi-user.target
EOF

