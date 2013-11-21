[ "$FREETZ_PATCH_GSMVOICE" == "y" ] || return 0
echo1 "enabling voice-over-gsm"

if [ "$FREETZ_AVM_HAS_ONLY_LUA" != "y" ]; then
	modsed \
	  "s/^\(return !isNaN(voiceStatus)\).*/\1;/" \
	  "${HTML_SPEC_MOD_DIR}/gsm/gsm.js" \
	  'return !isNaN(voiceStatus)'
else
	modsed \
	  's/^\(local voice_status=\).*/\11/' \
	  "${LUA_MOD_DIR}/umts.lua" \
	  'voice_status=1'
fi
