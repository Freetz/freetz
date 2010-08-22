[ "$FREETZ_ADD_REGEXT_GUI" == "y" ] || return 0
# own modsed, use --follow-symlink 
# and don't warn if file not found
# because fon1IPPhone.* files are not allways available; seems easier than something like 
# [ -x ${dir}/fon1IPPhone.<xy> ] && modsed ...

modsed()
{
	if [ -f "$2" ]; then
		echo2 "patching $2"
		sed -i --follow-symlink -e "$1" "$2"
	fi
}
echo1 "adding GUI switch to set reg_from_outside"

DIRSS2PATCH=$(find ${FILESYSTEM_MOD_DIR}/usr/www/ -type d -name fon_config)
if [ -n "$DIRSS2PATCH" ]; then
	for dir in $DIRSS2PATCH; do
		modsed '/id="uiPostIPPhoneExtNumber"/ a<Input type="hidden" name="voipextension:settings/extension<? echo $var:DeviceIpPhonePort ?>/reg_from_outside" value="" id="uiPostIPPhoneExtRegFromOutside" disabled>' ${dir}/fon_config_End.frm
		modsed '/jslEnable("uiPostIPPhoneExtNumber")/ ajslCopyValue( "uiPostIPPhoneExtRegFromOutside", "uiIPPhoneExtRegFromOutside"); jslEnable("uiPostIPPhoneExtRegFromOutside");' ${dir}/fon_config_End.js
		modsed '/id="uiShowOutgoingMsn"/ i<? if eq "$var:TechType" "IPPHONE" ` \n<tr><td class="c1"><span >reg_from_outside</span></td>\n<td class="c2">\n<? if eq "$var:IPPhoneExtRegFromOutside" "1"\n`\nyes\n` `\nno\n` ?>\n</td></tr>\n` ?>' ${dir}/fon_config_End.html
		modsed '/id="uiIPPhoneExtNumber"/ a<input type="hidden" name="var:IPPhoneExtRegFromOutside" value="<? echo $var:IPPhoneExtRegFromOutside ?>" id="uiIPPhoneExtRegFromOutside">' ${dir}/fon_config.frm
		modsed '/jslCopyValue( "uiIPPhoneExtNumber", "uiDevicePort")/ ajslSetValue( "uiIPPhoneExtRegFromOutside", (jslGetChecked("uiRegFromOutside"))? "1" : "0");' ${dir}/fon_config_IPPhone_1.js
		modsed '/<\/table>/ i<tr style="padding-top:15px;padding-bottom:15px;">\n<td style="width: 190px; height:30px;">Registrierung v. Extern</td>\n<td><input type="checkbox" name="reg_from_outside" id="uiRegFromOutside"></td>\n</tr>' ${dir}/fon_config_IPPhone_1.html
		modsed '/id="uiPostIPPhonePasswd"/ a<Input type="hidden" name="voipextension:settings/extension<? echo $var:DeviceIpPhonePort ?>/reg_from_outside" value="<? query voipextension:settings/extension<? echo $var:DeviceIpPhonePort ?>/reg_from_outside ?>" id="uiPostIPPhoneRegFromOutside">' ${dir}/fon1IPPhone.frm
		modsed '/function uiDoOnLoad()/,/function uiDoCancel()/ {s%jslDisplay("uiIP_General",true);%&\njslGetCheckValue( "uiRegFromOutside", "uiPostIPPhoneRegFromOutside");% 1 ; s%if (jslGetValue("uiViewPassword") \!="\*\*\*\*")%jslSetCheckValue( "uiPostIPPhoneRegFromOutside", "uiRegFromOutside");\n&%1}' ${dir}/fon1IPPhone.js
		modsed '/id="uiViewPassword"/ a</tr>\n<tr style="padding-top:15px;padding-bottom:15px;">\n<td style="width: 190px; height:30px;">Registrierung v. Extern</td>\n<td><input type="checkbox" name="reg_from_outside" id="uiRegFromOutside" value="0")"></td>' ${dir}/fon1IPPhone.html
	done
fi

