
echo1 "replacing onlinechanged"

if [ "$FREETZ_REPLACE_ONLINECHANGED" == "y" ]; then
	# Replace AVM onlinechanged by our own handler
	onlinechanged_cmd='# Do nothing for AVM onlinechanged, let /sbin/ip_watchdog handle it'

cat << 'EOF' > "${FILESYSTEM_MOD_DIR}/sbin/ip_watchdog"
#!/bin/sh

while true; do
	[ "$IP" ] && IP_OLD="$IP"
	IP="$(/usr/bin/get_ip)"
	[ "$IP" ] && [ "$IP" != "$IP_OLD" ] &&
		IPADDR=$IP /bin/onlinechanged.sh online &
	sleep 60
done
EOF

	chmod +x "${FILESYSTEM_MOD_DIR}/sbin/ip_watchdog"
else
	# Run in background, multid terminates the script
	onlinechanged_cmd='/bin/onlinechanged.sh "$@" &'
fi

rm -f "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"

cat << EOF > "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
#!/bin/sh
$onlinechanged_cmd
EOF

chmod +x "${FILESYSTEM_MOD_DIR}/bin/onlinechanged"
