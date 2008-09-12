if [ "$FREETZ_TYPE_FON_5010" == "y" ] || \
	[ "$FREETZ_TYPE_FON_5050" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7050" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7140" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7141" == "y" ] || \
	[ "$FREETZ_TYPE_FON_7150" == "y" ] || \
	[ "$FREETZ_TYPE_FON_WLAN_7170" == "y" ]
then
	echo1 "applying printk patch"
	sed -i -e "s/takeover_printk=1/takeover_printk=0/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
elif [ "$FREETZ_TYPE_FON_WLAN_7270" == "y" ]; then
	echo1 "applying printk patch"
	sed -i -e "s/AVM_PRINTK/STD_PRINTK/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
fi
