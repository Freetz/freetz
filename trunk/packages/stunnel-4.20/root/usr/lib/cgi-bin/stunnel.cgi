#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_c_chk=''; man_c_chk=''
auto_s_chk=''; man_s_chk=''

if [ "$STUNNEL_CLIENTENABLED" = "yes" ]; then auto_c_chk=' checked'; else man_c_chk=' checked'; fi
if [ "$STUNNEL_SERVERENABLED" = "yes" ]; then auto_s_chk=' checked'; else man_s_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<h2>$(lang de:"Client" en:"Client"):</h2>
<p>
<input id="e1" type="radio" name="clientenabled" value="yes"$auto_c_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="clientenabled" value="no"$man_c_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
<!--
<h2>$(lang de:"Server" en:"Server"):</h2>
<p>
<input id="e1" type="radio" name="serverenabled" value="yes"$auto_s_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="serverenabled" value="no"$man_s_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
-->

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
<li><a href="/cgi-bin/file.cgi?id=stunnel_clsvcs">$(lang de:"Client Dienste bearbeiten" en:"Edit client services file")</a></li>
<!--
<li><a href="/cgi-bin/file.cgi?id=stunnel_srvsvcs">$(lang de:"Server Dienste bearbeiten" en:"Edit server services file")</a></li>
-->
</ul>
EOF
sec_end
