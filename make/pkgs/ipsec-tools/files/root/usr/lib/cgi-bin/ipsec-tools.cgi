#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$IPSEC_TOOLS_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"K" en:"C")onfiguration"

cat << EOF
<table>
<tr><td>$(lang de:"Zertifikats-Name in Konfig" en:"Certificate file name in configuration")</td> <td> &nbsp;&nbsp; </td> <td><input name=certname value="$IPSEC_TOOLS_CERTNAME"></td></tr>
<tr><td>$(lang de:"Schl&uuml;ssel-Name in Konfig" en:"Key file name in configuration")</td> <td> &nbsp;&nbsp; </td> <td><input name=keyname value="$IPSEC_TOOLS_KEYNAME"></td></tr>
<tr><td>$(lang de:"CA-Name in Konfig" en:"CA name in configuration")</td> <td> &nbsp;&nbsp; </td> <td><input name=caname value="$IPSEC_TOOLS_CANAME"></td></tr>
<tr><td>$(lang de:"Datei mit preshared keys (PSK)" en:"preshared key file")</td> <td> &nbsp;&nbsp; </td> <td><input name=pskname value="$IPSEC_TOOLS_PSKNAME"></td></tr>
<tr><td>$(lang de:"Pfad zu Zertifikaten/Schl&uuml;ssel" en:"Path to certificates and key")</td> <td> &nbsp;&nbsp; </td> <td><input name=certpath value="$IPSEC_TOOLS_CERTPATH"></td></tr>

<tr><td>$(lang de:"Dynamischer DNS-Name der Gegenstelle" en:"Dynamic DNS name of remote site")</td> <td> &nbsp;&nbsp; </td> <td><input name=dyndns value="$IPSEC_TOOLS_DYNDNS"></td></tr>
<tr><td>$(lang de:"Lokale VPN-IP" en:"Local VPN IP")</td> <td> &nbsp;&nbsp; </td> <td><input name=vpn_local value="$IPSEC_TOOLS_VPN_LOCAL"></td></tr>
<tr><td>$(lang de:"Entfernte VPN-IP" en:"Remote VPN IP")</td> <td> &nbsp;&nbsp; </td> <td><input name=vpn_remote value="$IPSEC_TOOLS_VPN_REMOTE"></td></tr>

</table>
<p>
<select name="choice" size="1" onchange='neu=this.options[this.selectedIndex].value; document.getElementById(alt).style.display="none"; document.getElementById(neu).style.display="block"; alt=neu'>
document.getElementById("id_rules_li").style.display=(this.checked)? "block" : "none"'
<option value="id_racoon" selected="selected">racoon.conf</option>
<option value="id_crt">$(lang de:"Zertifikatsdatei" en:"cert file")</option>
<option value="id_key">$(lang de:"Schl&uuml;sseldatei" en:"key file")</option>
<option value="id_ca">$(lang de:"Zertifikat der CA" en:"CA cert file")</option>
<option value="id_setkey">setkey.conf</option>
<option value="id_psk">$(lang de:"PreShared Key-Datei" en:"PSK file")</option>
</select>
</p>

<p><div align="center"><textarea id="id_racoon" style="width: 500px; display:block" name="racoon" rows="15" cols="80" wrap="off" >$IPSEC_TOOLS_RACOON</textarea></div></p>
<p><div align="center"><textarea id="id_crt" style="width: 500px; display:none" name="crt" rows="15" cols="80" wrap="off">$IPSEC_TOOLS_CRT</textarea></div></p>
<p><div align="center"><textarea id="id_key" style="width: 500px; display:none" name="key" rows="15" cols="80" wrap="off" >$IPSEC_TOOLS_KEY</textarea></div></p>
<p><div align="center"><textarea id="id_ca" style="width: 500px; display:none" name="ca" rows="15" cols="80" wrap="off">$IPSEC_TOOLS_CA</textarea></div></p>
<p><div align="center"><textarea id="id_setkey" style="width: 500px; display:none" name="setkey" rows="15" cols="80" wrap="off" >$IPSEC_TOOLS_SETKEY</textarea></div></p>
<p><div align="center"><textarea id="id_psk" style="width: 500px; display:none" name="psk" rows="15" cols="80" wrap="off" >$IPSEC_TOOLS_PSK</textarea></div></p>
<p></p>

<script>
alt="id_racoon";
</script>
EOF

sec_end
