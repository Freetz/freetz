#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_c_chk=''; man_c_chk=''
auto_s_chk=''; man_s_chk=''

if [ "$STUNNEL_ENABLED" = "yes" ]; then auto_c_chk=' checked'; else man_c_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_c_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_c_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<h2>$(lang de:"Erweiterte Einstellungen" en:"Advanced settings"):</h2>
<p>$(lang de:"OpenSSL Optionen" en:"OpenSSL options"): <input id="ssloptions" type="text" name="ssloptions" size="20" maxlength="255" value="$(httpd -e "$STUNNEL_SSLOPTIONS")"></p>
<p>$(lang de:"Log-Level" en:"Verbosity level"): <input id="verbose" type="text" name="verbose" size="20" maxlength="50" value="$(httpd -e "$STUNNEL_VERBOSE")"></p>
EOF
sec_end
sec_begin '$(lang de:"Dienste" en:"Services")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=stunnel_svcs">$(lang de:"Dienste bearbeiten" en:"Edit services file")</a></li>
<li><a href="/cgi-bin/file.cgi?id=stunnel_pem">$(lang de:"Zertifikat und privaten Schlüssel für Server-Modus bearbeiten" en:"Edit certificate and private key for server mode")</a></li>
</ul>
EOF
sec_end
