[ "$FREETZ_REMOVE_ASSISTANT" == "y" ] || return 0
echo1 "removing assistant"

# from m*.* mod

rm_files \
  "${HTML_SPEC_MOD_DIR}/konfig" \
  "${HTML_LANG_MOD_DIR}/html/index_assi.html" \
  "${HTML_LANG_MOD_DIR}/html/assistent.html"

if [ "$FREETZ_REMOVE_ASSISTANT_SIP" == "y" ]; then
	if [ "$FREETZ_AVM_HAS_ONLY_LUA" != "y" ]; then
		# Don't delete provider.js because it's referenced by other files.
		find "${HTML_SPEC_MOD_DIR}/first" -type f -not -name "provider.js" -exec rm {} \;
	fi
else
	# Needed by "neue Rufnummer": first.frm , lib.js , *bb_backokcancel.html , first_Sip_(1|2|3)*
	rm_files \
	  "${HTML_SPEC_MOD_DIR}/first/*_ISP*" \
	  "${HTML_SPEC_MOD_DIR}/first/basic_first*" \
	  "${HTML_SPEC_MOD_DIR}/first/first_Sip_free.*" \
	  "${HTML_SPEC_MOD_DIR}/first/first_Start_Sip.*" \
	  "${HTML_SPEC_MOD_DIR}/first/first_SIP_UI_*"
fi

if [ "$FREETZ_AVM_HAS_ONLY_LUA" != "y" ]; then
	find "${HTML_SPEC_MOD_DIR}/menus" -type f | xargs sed -s -i -e '/var:menuAssistent/d'
fi

if [ ! -e "$HTML_SPEC_MOD_DIR/home/sitemap.html" ]; then
	# removes link on the left (06.00)
	linkbox_remove wizards
	# removes link on the left (06.50)
	modern_remove wizOv
else
	if [ "$FREETZ_AVM_VERSION_05_2X_MIN" == "y" ]; then
		#lua
		linkbox_remove wizards
		#html
		linkbox_file="${HTML_SPEC_MOD_DIR}/menus/menu2.html"
		linkbox_row=$(cat $linkbox_file |nl| sed -n "s/^ *\([0-9]*\).*<a href=.javascript:jslGoTo.'konfig','home'..>.*<.a>$/\1/p")
		modsed "$((linkbox_row-13)),$((linkbox_row+19))d" $linkbox_file
	elif isFreetzType 7112 7113 7141 7150 7170 7270_V1 7570; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/220-remove_assistant/remove_assistant_${FREETZ_TYPE_LANGUAGE}_${FREETZ_TYPE_PREFIX}.patch"
	elif isFreetzType 7140; then
		if isFreetzType LANG_A_CH; then
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/220-remove_assistant/remove_assistant_de_7140.patch"
		else
			modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/220-remove_assistant/remove_assistant_de.patch"
		fi
	elif [ "$FREETZ_AVM_HAS_PHONE" == "y" ]; then
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/220-remove_assistant/remove_assistant_de.patch"
	else
		modpatch "$FILESYSTEM_MOD_DIR" "${PATCHES_COND_DIR}/220-remove_assistant/remove_assistant_de_wop.patch"
	fi
fi

# even if box is unconfigured do not try to address assistant-pages but home
[ -e "${HTML_LANG_MOD_DIR}/html/logincheck.html" ] && modsed \
  '/uiPostPageName", "first_/{N;s/.*\n.*$/jslSetValue("uiPostPageName", "home");\njslSetValue("uiPostMenu", "home");/g}' \
  "${HTML_LANG_MOD_DIR}/html/logincheck.html"
# for all 'jslSetValue("uiPostPageName"' (Annex/Country/Language) use this:
# '/uiPostPageName",.*first_/{N;s/.*\n.*$/jslSetValue("uiPostPageName", "home");\njslSetValue("uiPostMenu", "home");/g}' \
modsed \
  's/^http.redirect(get_goto_oldassi_href.*/go_home()/' \
  "${LUA_MOD_DIR}/first.lua"

