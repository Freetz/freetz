isFreetzType 7270_V1 7412 7430 && return 0
echo1 "applying printk patch"

file="$FILESYSTEM_MOD_DIR/etc/init.d/rc.S"
if grep -q 'takeover_printk=' "$file" 2>/dev/null; then
	modsed "s/takeover_printk=1/takeover_printk=0/g" "$file" "takeover_printk=0"
fi

for file in rc.S S17-isdn S11-piglet; do
	if grep -q 'AVM_PRINTK' "$FILESYSTEM_MOD_DIR/etc/init.d/$file" 2>/dev/null; then
		modsed "s/AVM_PRINTK/STD_PRINTK/g" "$FILESYSTEM_MOD_DIR/etc/init.d/$file" "STD_PRINTK"
	fi
	if grep -q '^cat \/dev\/debug' "$FILESYSTEM_MOD_DIR/etc/init.d/$file" 2>/dev/null; then
		modsed "/^cat \/dev\/debug.*$/ s/^/: #/g" "$FILESYSTEM_MOD_DIR/etc/init.d/$file"
	fi
done
