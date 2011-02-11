[ "$FREETZ_PATCH_VCC" == "y" ] || return 0
echo1 "applying vcc patch"
if [ -e "${HTML_LANG_MOD_DIR}/html/de" ];then
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/de"
else
	HTML_DIR="${HTML_LANG_MOD_DIR}/html/en"
fi

WS0='[ \t]*'
WS1='[ \t]\+'
SHOWUIVCC_PRIOR80FIRMWARE="s,\(setvariable${WS1}var:ShowUiVcc\)${WS1}0,\1 1,g"
SHOWUIVCC_AFTER80FIRMWARE="s,\(showUiVcc${WS0}=${WS0}\)false,\1true,g"
SHOWUIVCC_FREENET="s,&&${WS0}\!${WS0}(${WS0}IsISPFreenet()${WS0}&&${WS0}IsNonFestnetzActiv()${WS0}),\|\| g_Oem == \"freenet\",g"
modsed "${SHOWUIVCC_PRIOR80FIRMWARE};${SHOWUIVCC_AFTER80FIRMWARE};${SHOWUIVCC_FREENET};" "${HTML_DIR}/fon/sipoptionen.js"
unset WS0 WS1 SHOWUIVCC_PRIOR80FIRMWARE SHOWUIVCC_AFTER80FIRMWARE SHOWUIVCC_FREENET

if isFreetzType W501V W701V W901V; then
	modsed "s/avme/tcom/g" "${HTML_DIR}/fon/sipoptionen.js"
fi

# Model
#modsed '/id="uiPostVci"/ a<input type="hidden" name="connection_voip:settings/traffic_class" value="<? query connection_voip:settings/traffic_class ?>" id="uiPostTrafficClass" disabled />' "${HTML_DIR}/fon/sipoptionen.frm"
modsed '/id="uiPostVci"/ a<input type="hidden" name="connection_voip:settings/scr" value="<? query connection_voip:settings/scr ?>" id="uiPostScr" disabled />' "${HTML_DIR}/fon/sipoptionen.frm"
modsed '/id="uiPostVci"/ a<input type="hidden" name="connection_voip:settings/pcr" value="<? query connection_voip:settings/pcr ?>" id="uiPostPcr" disabled />' "${HTML_DIR}/fon/sipoptionen.frm"

# Model -> View
#modsed '/jslCopyValue( *"uiViewVCI" *, *"uiPostVci" *)/ aif (jslGetValue("uiPostTrafficClass")=="atm_traffic_class_CBR") {\njslSetSelection("uiViewTrafficClass","CBR");\n} else if (jslGetValue("uiPostTrafficClass")=="atm_traffic_class_VBR") {\njslSetSelection("uiViewTrafficClass","VBR");\n} else {\njslSetSelection("uiViewTrafficClass","UBR");\n}' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslCopyValue( *"uiViewVCI" *, *"uiPostVci" *)/ ajslCopyValue("uiViewScr", "uiPostScr");' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslCopyValue( *"uiViewVCI" *, *"uiPostVci" *)/ ajslCopyValue("uiViewPcr", "uiPostPcr");' "${HTML_DIR}/fon/sipoptionen.js"

# Model objects to copy
#modsed '/jslEnable( *"uiPostVci" *)/ ajslEnable("uiPostTrafficClass");' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslEnable( *"uiPostVci" *)/ ajslEnable("uiPostScr");' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslEnable( *"uiPostVci" *)/ ajslEnable("uiPostPcr");' "${HTML_DIR}/fon/sipoptionen.js"

# validation messages
modsed '/var g_VCIMustNumber/ avar g_SCRMustNumber = "SCR: Ungültige Eingabe, es sind nur Ziffern erlaubt.";' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/var g_VCIMustNumber/ avar g_PCRMustNumber = "PCR: Ungültige Eingabe, es sind nur Ziffern erlaubt.";' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/var g_VCIOutOfRange/ avar g_SCROutOfRange = "SCR: Ungültige Eingabe, es sind Eingaben zwischen 0 und 65535 erlaubt.";' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/var g_VCIOutOfRange/ avar g_PCROutOfRange = "PCR: Ungültige Eingabe, es sind Eingaben zwischen 0 und 65535 erlaubt.";' "${HTML_DIR}/fon/sipoptionen.js"

# View -> Model, local variables
modsed '/vci *= *jslGetValue("uiViewVCI")/ avar scr = jslGetValue("uiViewScr");' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/vci *= *jslGetValue("uiViewVCI")/ avar pcr = jslGetValue("uiViewPcr");' "${HTML_DIR}/fon/sipoptionen.js"

# View -> Model, validation
modsed '/alert(g_VCIOutOfRange)/ aif (!valIsZahlVorhanden(scr)) {alert(g_SCRMustNumber); return false;}\nif ((scr < 0) || (scr > 65535)) {alert(g_SCROutOfRange); return false;}' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/alert(g_VCIOutOfRange)/ aif (!valIsZahlVorhanden(pcr)) {alert(g_PCRMustNumber); return false;}\nif ((pcr < 0) || (pcr > 65535)) {alert(g_PCROutOfRange); return false;}' "${HTML_DIR}/fon/sipoptionen.js"

# View -> Model
#modsed '/jslSetValue( *"uiPostVci" *, *vci *)/ ajslSetValue("uiPostTrafficClass", "atm_traffic_class_"+jslGetValue("uiViewTrafficClass"));' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslSetValue( *"uiPostVci" *, *vci *)/ ajslSetValue("uiPostScr", scr);' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslSetValue( *"uiPostVci" *, *vci *)/ ajslSetValue("uiPostPcr", pcr);' "${HTML_DIR}/fon/sipoptionen.js"

# enable/disable UI controls
#modsed '/jslSetEnabled( *"uiViewVCI" *, *b *)/ ajslSetEnabled("uiViewTrafficClass",b);' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslSetEnabled( *"uiViewVCI" *, *b *)/ ajslSetEnabled("uiViewScr",b);' "${HTML_DIR}/fon/sipoptionen.js"
modsed '/jslSetEnabled( *"uiViewVCI" *, *b *)/ ajslSetEnabled("uiViewPcr",b);' "${HTML_DIR}/fon/sipoptionen.js"

# UI controls instantiation
#modsed '/id="uiViewVCI"/ a</tr>\n<tr>\n<td><label for="uiViewTrafficClass">Traffic Class</label></td>\n<td><select id="uiViewTrafficClass" class="Eingabefeld">\n<option>UBR</option>\n<option>CBR</option>\n<option>VBR</option>\n</select></td>' "${HTML_DIR}/fon/sipoptionen.html"
modsed '/id="uiViewVCI"/ a</tr>\n<tr>\n<td><label for="uiViewScr">SCR</label></td>\n<td><input type="text" size="5" maxlength="5" class="Eingabefeld" id="uiViewScr"></td>' "${HTML_DIR}/fon/sipoptionen.html"
modsed '/id="uiViewVCI"/ a</tr>\n<tr>\n<td><label for="uiViewPcr">PCR</label></td>\n<td><input type="text" size="5" maxlength="5" class="Eingabefeld" id="uiViewPcr"></td>' "${HTML_DIR}/fon/sipoptionen.html"
