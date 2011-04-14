
echo1 "patching /bin/onlinechanged"

rm -f "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

eventadd 1 "Running onlinechanged: $@"
logger -t ONLINECHANGED "going $@"
for i in /etc/onlinechanged/* /tmp/onlinechanged /tmp/flash/onlinechanged/*; do
	[ ! -s "$i" ] && continue
	logger -t ONLINECHANGED "is executing $i"
	sh "$i" "$@" 2>&1 | while read line; do logger -t ONLINECHANGED "$line"; done
done
EOF

chmod +x "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
