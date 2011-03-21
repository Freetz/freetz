if isFreetzType 5010 5050 7050 7140 7141 7150 7170; then
	echo1 "applying printk patch"
	modsed "s/takeover_printk=1/takeover_printk=0/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
#elif isFreetzType 3270 7240 7270; then
#	echo1 "applying printk patch"
#	modsed "s/AVM_PRINTK/STD_PRINTK/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
fi

if isFreetzType 7320 || (isFreetzType 7390 && isFreetzType LABOR_PREVIEW); then
	file="$FILESYSTEM_MOD_DIR/etc/init.d/S17-isdn"
elif isFreetzType LABOR_PREVIEW && isFreetzType 7270; then
	file="$FILESYSTEM_MOD_DIR/etc/init.d/S11-piglet"
else
	file="$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
fi
modsed "/^cat \/dev\/debug.*$/ s/^/: #/g" $file