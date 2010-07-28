isFreetzType PREVIEW || return 0

echo1 "Fix name resolution for AVM daemons"

cat > "${VARTAR_MOD_DIR}/var/tmp/avm-resolv.conf" << EOF
nameserver 169.254.180.1
nameserver 169.254.180.2
EOF