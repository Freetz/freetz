echo1 "applying printk patch"

file="$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
if isFreetzType 5010 5050 7050 7140 7141 7150 7170; then
	modsed "s/takeover_printk=1/takeover_printk=0/g" $file "takeover_printk=0"
else
	for conf_script in S17-isdn S11-piglet; do
		[ ! -e "$FILESYSTEM_MOD_DIR/etc/init.d/$conf_script" ] && continue
		file="$FILESYSTEM_MOD_DIR/etc/init.d/$conf_script"
		modsed "s/AVM_PRINTK/STD_PRINTK/g" $file "STD_PRINTK"
	done
fi
modsed "/^cat \/dev\/debug.*$/ s/^/: #/g" $file
