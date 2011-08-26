echo1 "applying printk patch"

if isFreetzType 5010 5050 7050 7140 7141 7150 7170; then
	modsed "s/takeover_printk=1/takeover_printk=0/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
	file="$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
elif isFreetzType 7320 7390; then
	file="$FILESYSTEM_MOD_DIR/etc/init.d/S17-isdn"
	modsed "s/AVM_PRINTK/STD_PRINTK/g" $file
elif isFreetzType 3270 3270_V3 7240 7270_V2 7270_V3; then
	file="$FILESYSTEM_MOD_DIR/etc/init.d/S11-piglet"
	modsed "s/AVM_PRINTK/STD_PRINTK/g" $file
else
	file="$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
fi
modsed "/^cat \/dev\/debug.*$/ s/^/: #/g" $file
