
echo1 "Patching /bin/onlinechanged"

rm -f "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

for i in /etc/onlinechanged/* /tmp/onlinechanged /tmp/flash/onlinechanged/*; do
    test -f "$i" && sh "$i" "$@"
done
EOF

chmod +x "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
