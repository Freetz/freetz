[ "$FREETZ_PATCH_GSMVOICE" == "y" ] || return 0
echo1 "enabling voice-over-gsm"

for file in ${FILESYSTEM_MOD_DIR}/usr/www/*/html/de/gsm/gsm.js; do
	modsed "s/^\(return !isNaN(voiceStatus)\).*/\1;/" $file 'return !isNaN(voiceStatus)'
done

