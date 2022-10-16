#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$DROPBEAR_ENABLED" "" "" 1
sec_end

if [ "$FREETZ_PACKAGE_AUTHORIZED_KEYS" == "y" ]; then
sec_begin "$(lang de:"Public Key Authentication" en:"Public key authentication")"
cat << EOF
<ul>
<li><a href="$(href file authorized-keys authorized_keys)">$(lang de:"authorized_keys bearbeiten" en:"Edit authorized_keys")</a></li>
</ul>
EOF
sec_end
fi

sec_begin "$(lang de:"SSH-Server" en:"SSH server")"
cat << EOF
<h2>$(lang de:"Der SSH-Server ist gebunden an" en:"The SSH server is listening on"):</h2>
EOF
cgi_print_textline_p "port" "$DROPBEAR_PORT" 5 "Port:"
cat << EOF
<h2>Login</h2>
<p>
EOF

cgi_print_checkbox_br "pwdauth" "$DROPBEAR_PWDAUTH" "$(lang de:"Passwort-Login erlauben" en:"Allow password login")"
cgi_print_checkbox_br "rootonly" "$DROPBEAR_ROOTONLY" "$(lang de:"Login nur f&uuml;r root erlauben" en:"Allow only root login")"

cat << EOF
<p style="font-size:10px;">$(lang de:"Bitte beachte, dass die FRITZ!Box keine ad&auml;quate Benutzerverwaltung bietet. Die Dateien /etc/passwd und /etc/shadow m&uuml;ssen mit <b>modsave</b> gespeichert werden. Bitte aktiviere die Unterst&uuml;tzung f&uuml;r normale Benutzer nur, wenn Du genau wei&szlig;t, was Du tust." en:"Please note that the FRITZ!Box does not support normal user management. The files /etc/passwd and /etc/shadow have to be saved with <b>modsave</b>. Please activate the support for regular users only if you know what you are doing.")</p>
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
EOF
cgi_print_textline_p "options" "$DROPBEAR_OPTIONS" 20/255 "$(lang de:"Optionen" en:"Options"):"
sec_end

