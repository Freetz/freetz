[ "$FREETZ_REMOVE_SUPPORT" == "y" ] || return 0
[ "$FREETZ_REMOVE_SUPPORT_EVENTSDUMP" == "y" ] && _eventsdump="-name eventsdump -o"
echo1 "remove support files"
rm_files \
  $(find ${FILESYSTEM_MOD_DIR}/sbin -maxdepth 1 $_eventsdump -name showaddrs -o -name showroutes | xargs) \
  "${FILESYSTEM_MOD_DIR}/bin/showvoipdstat" \
  "${FILESYSTEM_MOD_DIR}/bin/supportdata*" \
  "${HTML_MOD_DIR}/all/support.lua" \
  "${HTML_LANG_MOD_DIR}/html/support*.html"
