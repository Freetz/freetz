#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$STUNNEL_ENABLED" yes:auto_c "*":man_c

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
<p>$(lang de:"OpenSSL Optionen" en:"OpenSSL options"): <input id="ssloptions" type="text" name="ssloptions" size="20" maxlength="255" value="$(html "$STUNNEL_SSLOPTIONS")"></p>
<p>$(lang de:"Log-Level" en:"Verbosity level"): <input id="verbose" type="text" name="verbose" size="20" maxlength="50" value="$(html "$STUNNEL_VERBOSE")"></p>
EOF
sec_end
sec_begin '$(lang de:"Dienste" en:"Services")'

cat << EOF
<ul>
<li><a href="$(href file stunnel svcs)">$(lang de:"Dienste bearbeiten" en:"Edit services file")</a></li>
<li><a href="$(href file stunnel certchain)">$(lang de:"Zertifikats-Kette bearbeiten" en:"Edit certificate chain")</a></li>
<li><a href="$(href file stunnel key)">$(lang de:"Privaten Schlüssel bearbeiten" en:"Edit private key")</a></li>
</ul>
EOF
sec_end
