echo1 "applying busybox' NOEXEC/NOFORK related workarounds"
for file in rc.S S17-isdn S11-piglet; do
	if grep -qE '(^|[ \t#])cat[ \t]+/dev/debug' "$FILESYSTEM_MOD_DIR/etc/init.d/$file" 2>/dev/null; then
		modsed -r "s,((^|[ \t#]))(cat[ \t]+/dev/debug),\1/bin/\3," "$FILESYSTEM_MOD_DIR/etc/init.d/$file"
	fi
done
