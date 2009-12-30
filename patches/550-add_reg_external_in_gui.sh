[ "$FREETZ_ADD_REGEXT_GUI" == "y" ] || return 0
echo1 "adding GUI switch to set reg_from_outside"

DIRSS2PATCH=$(find ${FILESYSTEM_MOD_DIR}/usr/www/ -name fon_config)
if  [ $DIRSS2PATCH ]; then
	for dir in $DIRSS2PATCH; do
	 	echo1 " -- Patching settings in $dir:"
		modsed  '/id="uiPostIPPhoneExtNumber"/ a<Input type="hidden" name="voipextension:settings/extension<? echo $var:DeviceIsdnPort ?>/reg_from_outside" value="" id="uiPostIPPhoneExtRegFromOutside" disabled>' ${dir}/fon_config_End.frm
		modsed  '/jslEnable("uiPostIPPhoneExtNumber")/ ajslCopyValue( "uiPostIPPhoneExtRegFromOutside", "uiIPPhoneExtRegFromOutside"); jslEnable("uiPostIPPhoneExtRegFromOutside");' ${dir}/fon_config_End.js
		modsed  '/id="uiShowOutgoingMsn"/ i<? if eq "$var:TechType" "IPPHONE" ` \n<tr><td class="c1"><span >reg_from_outside</span></td>\n<td class="c2">\n<? if eq "$var:IPPhoneExtRegFromOutside" "1"\n`\nyes\n` `\nno\n` ?>\n</td></tr>\n` ?>' ${dir}/fon_config_End.html
		modsed  '/id="uiIPPhoneExtNumber"/ a<input type="hidden" name="var:IPPhoneExtRegFromOutside" value="<? echo $var:IPPhoneExtRegFromOutside ?>" id="uiIPPhoneExtRegFromOutside">' ${dir}/fon_config.frm
		modsed  '/jslCopyValue( "uiIPPhoneExtNumber", "uiDevicePort")/ ajslCopyValue( "uiIPPhoneExtRegFromOutside", "uiRegFromOutside");' ${dir}/fon_config_IPPhone_1.js
		modsed  "/<\/table\>/ i<tr style=\"padding-top:15px;padding-bottom:15px\;\"\>\n<td style=\"width: 190px\; height:30px\;\"\>Registrierung v. Extern<\/td\>\n<td\><input type=\"checkbox\" name=\"reg_from_outside\" id=\"uiRegFromOutside\" value=\"0\" onclick='\(this.value=\(this.checked\)? \"1\" : \"0\"\)'></td\>\n</tr\>" ${dir}/fon_config_IPPhone_1.html
	done
fi

