[ "$FREETZ_REMOVE_SUPPORT" == "y" ] || return 0
echo1 "remove support files"
rm_files $(find ${FILESYSTEM_MOD_DIR}/sbin -maxdepth 1 -name eventsdump \
		-o -name showdsldstat -o -name showvoipdstat -o -name showaddrs -o -name showroutes | xargs) \
	 "${FILESYSTEM_MOD_DIR}/bin/supportdata*" \
	 "${HTML_LANG_MOD_DIR}/html/support*.html"
