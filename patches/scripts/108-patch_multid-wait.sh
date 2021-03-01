[ "$FREETZ_AVM_VERSION_06_5X_MAX" == "y" ] || return 0
echo1 "applying multid-wait for netif"

if [ -e "$FILESYSTEM_MOD_DIR/sbin/multid" ]; then
	echo2 "applying multid-wait patch"
	modsed \
	  's@\(eval.*multid $.*PARAM\)@\1\nlocal countdown=10; while [ $((countdown--)) -gt 0 ] \&\& ! ifconfig eth0 >/dev/null 2>\&1; do sleep 1; done@g' \
	  "$FILESYSTEM_MOD_DIR/etc/init.d/rc.net" \
	  'local countdown=10'
else
	echo2 "no multid found, skipping multid-wait patch"
fi

