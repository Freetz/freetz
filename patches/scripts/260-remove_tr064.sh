[ "$FREETZ_REMOVE_TR064" == "y" ] || return 0
echo1 "removing tr064"

[ "$FREETZ_AVM_VERSION_07_25_MAX" == "y" ] && \
  rm_files \
  "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr069.so"

rm_files \
  "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libtr064.so" \
  "${FILESYSTEM_MOD_DIR}/etc/websrv_tr064_ssl_key.pem"

# patcht Heimnetz > Netzwerk > Netzwerkeinstellungen > Heimnetzfreigaben > Zugriff für Anwendungen zulassen
sedfile="${HTML_LANG_MOD_DIR}/net/network_settings.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	#<input type="checkbox" id="uiViewSetTr064" name="set_tr_064" <?lua if g_var.tr064_enabled then box.out('checked') end ?>>
	#<label for="uiViewSetTr064">{?859:511?}</label>
	#<p class="form_checkbox_explain">
	#{?859:2438?}
	#</p>
	#<p class="form_checkbox_explain">
	#{?859:144?}
	#</p>
	mod_del_area \
	  'id="uiViewSetTr064"' \
	  0 \
	  '{?859:144?}' \
	  1 \
	  $sedfile
	# remove sub header if also upnp is removed
	if [ "$FREETZ_REMOVE_UPNP" == "y" ]; then
		#<h4>
		#{?859:570?}
		#</h4>
		mod_del_area \
		  '{?859:570?}' \
		  -1 \
		  +1 \
		  $sedfile
		#if (general.is_expert()) then box.out([[<hr>]]) end
		modsed '/general.is_expert.*then.box.out.*hr.*end/d' $sedfile
	fi
fi

echo1 "patching /etc/init.d/rc.conf"
modsed "s/CONFIG_TR064=.*$/CONFIG_TR064=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "CONFIG_TR064=\"n\"$"

