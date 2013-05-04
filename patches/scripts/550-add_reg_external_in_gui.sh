[ "$FREETZ_ADD_REGEXT_GUI" == "y" ] || return 0

echo1 "adding GUI switch to set reg_from_outside"

SEARCHSTR='-name fon_config_End.[f|h|j]*  -o -name fon_config.frm -o -name fon_config_IPPhone_1.[j|h]*'
isFreetzType 7240 7270 7390 && SEARCHSTR="$SEARCHSTR"' -o -name fon1IPPhone*'

for file_n in $(find ${FILESYSTEM_MOD_DIR}/usr/www/ -type f  \( $SEARCHSTR \) -print); do
	case $(basename "$file_n") in
		fon_config_End.frm)
			modsed '/id="uiPostIPPhoneExtNumber"/ a<Input type="hidden" name="voipextension:settings/extension<? echo $var:DeviceIpPhonePort ?>/reg_from_outside" value="" id="uiPostIPPhoneExtRegFromOutside" disabled>' "$file_n"
			;;
		fon_config_End.js)
			modsed '/jslEnable("uiPostIPPhoneExtNumber")/ ajslCopyValue( "uiPostIPPhoneExtRegFromOutside", "uiIPPhoneExtRegFromOutside"); jslEnable("uiPostIPPhoneExtRegFromOutside");' "$file_n"
			;;
		fon_config_End.html)
			modsed '/id="uiShowOutgoingMsn"/ i<? if eq "$var:TechType" "IPPHONE" ` \n<tr><td class="c1"><span >reg_from_outside</span></td>\n<td class="c2">\n<? if eq "$var:IPPhoneExtRegFromOutside" "1"\n`\nyes\n` `\nno\n` ?>\n</td></tr>\n` ?>' "$file_n"
			;;
		fon_config.frm)
			modsed '/id="uiIPPhoneExtNumber"/ a<input type="hidden" name="var:IPPhoneExtRegFromOutside" value="<? echo $var:IPPhoneExtRegFromOutside ?>" id="uiIPPhoneExtRegFromOutside">' "$file_n"
			;;
		fon_config_IPPhone_1.js)
			modsed '/jslCopyValue( "uiIPPhoneExtNumber", "uiDevicePort")/ ajslSetValue( "uiIPPhoneExtRegFromOutside", (jslGetChecked("uiRegFromOutside"))? "1" : "0");' "$file_n"
			;;
		fon_config_IPPhone_1.html)
			modsed '/<\/table>/ i<tr style="padding-top:15px;padding-bottom:15px;">\n<td style="width: 190px; height:30px;">Registrierung v. Extern</td>\n<td><input type="checkbox" name="reg_from_outside" id="uiRegFromOutside"></td>\n</tr>' "$file_n"
			;;
		fon1IPPhone.frm)
			modsed '/id="uiPostIPPhonePasswd"/ a<Input type="hidden" name="voipextension:settings/extension<? echo $var:DeviceIpPhonePort ?>/reg_from_outside" value="<? query voipextension:settings/extension<? echo $var:DeviceIpPhonePort ?>/reg_from_outside ?>" id="uiPostIPPhoneRegFromOutside">' "$file_n"
			;;
		fon1IPPhone.js)
			modsed '/function uiDoOnLoad()/,/function uiDoCancel()/ {s%jslDisplay("uiIP_General",true);%&\njslGetCheckValue( "uiRegFromOutside", "uiPostIPPhoneRegFromOutside");% 1 ; s%if (jslGetValue("uiViewPassword") \!="\*\*\*\*")%jslSetCheckValue( "uiPostIPPhoneRegFromOutside", "uiRegFromOutside");\n&%1}' "$file_n"
			;;
		fon1IPPhone.html)
			modsed '/id="uiViewPassword"/ a</tr>\n<tr style="padding-top:15px;padding-bottom:15px;">\n<td style="width: 190px; height:30px;">Registrierung v. Extern</td>\n<td><input type="checkbox" name="reg_from_outside" id="uiRegFromOutside" value="0")"></td>' "$file_n"
			;;
		*)
			warn "No Patch found for \"$file_n\" in patch for \"reg_from_outside\""
			;;
	esac
	grep -q "RegFromOutside" "$file_n" && echo2 "  added Reg From Outside to file: ${file_n##*/}"
done
