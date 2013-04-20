[ "$FREETZ_PATCH_GSMVOICE" == "y" ] || return 0
echo1 "enabling voice-over-gsm"

modsed \
  "s/^\(return !isNaN(voiceStatus)\).*/\1;/" \
  "${HTML_SPEC_MOD_DIR}/gsm/gsm.js" \
  'return !isNaN(voiceStatus)'

