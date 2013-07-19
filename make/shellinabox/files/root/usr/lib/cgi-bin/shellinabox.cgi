#!/bin/sh

if  $(echo "$QUERY_STRING" | grep -q dogencert ); then
        sh /mod/etc/default.shellinabox/generate_cert.sh
        echo '<textarea id="certout">'
        cat /tmp/shellinabox_certificate.pem
        echo '</textarea>'
        echo '<script>parent.document.getElementById("id_cert").value=document.getElementById("certout").value</script>'
        rm /tmp/shellinabox_certificate.pem
        exit
fi

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$SHELLINABOX_ENABLED" yes:auto "*":man
check "$SHELLINABOX_NOSSL" true:ssldis
if [ "$SHELLINABOX_NOSSL" = true  -o "$FREETZ_PACKAGE_SHELLINABOX_SSL" != "y" ]; then
	displayssl="none"
else
	displayssl="block"
fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<table>
<tr>
<td><i>Port:</i></td>
<td><input type="text" name="port" size="10" maxlength="5" value="$(html "$SHELLINABOX_PORT")"></td>
EOF

if [ "$FREETZ_PACKAGE_SHELLINABOX_SSL" == "y" ]; then
cat << EOF
<td><i>$(lang de:"SSL deaktivieren" en:"Disable SSL"):</i> &nbsp; <input id="id_ssl" type="checkbox" name="nossl" value="true"$ssldis_chk onclick='(document.getElementById("div_cert").style.display=(this.checked)? "none" : "block")'></td>
EOF
fi

cat << EOF
</tr>
<tr>
<td><i>Service:</i></td>
<td colspan=3><input type="text" name="service" size="40" value="$(html "$SHELLINABOX_SERVICE")"></td>
</tr>
</table>
<div style="display:$displayssl" id="div_cert">
<p>$(lang de:"Zertifikat" en:"Certificate")
<div align="center"><textarea id="id_cert" style="width: 500px;" name="cert" rows="15" cols="80" wrap="off">$SHELLINABOX_CERT</textarea></div></p>
EOF

if which openssl_req >/dev/null 2>&1; then
cat << EOF
$(lang de:"Die Box kann ein minimales, selbst signiertes Zertifikat erstellen. Das dauert etwas..." en:"This will build a self signed certificate on the box. Will take some time..")
<iframe name="dummy" id="id_iframe" style="display:none;" width=500 height=100 frameborder="0"> </iframe>
<input type="button" value="$(lang de:"Zertifikat erstellen" en:"Generate certificate")" onclick='document.getElementById("id_iframe").src="/cgi-bin/conf/shellinabox?dogencert"; target="dummy"'>
EOF
fi

cat << EOF
</div>
<h2>$(lang de:"Andere Optionen" en:"Additional options"):</h2>
<p><input type="text" name="options" size="60" maxlength="255" value="$(html "$SHELLINABOX_OPTIONS")"></p>
EOF

sec_end

