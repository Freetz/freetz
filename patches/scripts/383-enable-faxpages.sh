[ "$FREETZ_PATCH_FAXPAGES" == "y" ] || return 0
echo1 "enabling multiple-fax-pages"

modsed \
  's/accept="image\/\*">/accept="image\/\*" multiple="multiple">/' \
  "${HTML_LANG_MOD_DIR}/fon_devices/fax_send.lua" \
  'multiple="multiple">'

