#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$OPENSSH_PWDAUTH" yes:pwdauth_yes "*":pwdauth_no
check "$OPENSSH_ROOT" yes:root_yes "*":root_no

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$OPENSSH_ENABLED" "" "" 1
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

sec_begin "$(lang de:"SSH Server" en:"SSH server")"
cat << EOF
<p><i>$(lang de:"Der SSH Server ist gebunden an" en:"The SSH server is listening on"):</i>
Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$OPENSSH_PORT")"></p>
<p><i>$(lang de:"Passwort Login zulassen" en:"enable password login"):</i>
<input id="p1" type="radio" name="pwdauth" value="yes"$pwdauth_yes_chk><label for="p1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="p2" type="radio" name="pwdauth" value="no"$pwdauth_no_chk><label for="p2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<p><i>$(lang de:"Login f&uuml;r root erlauben" en:"Allow root login"):</i>
<input id="r1" type="radio" name="root" value="yes"$root_yes_chk><label for="r1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="r2" type="radio" name="root" value="no"$root_no_chk><label for="r2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<p style="font-size:10px;">$(lang de:"Bitte beachte, dass die FRITZ!Box kein ad&auml;quates Benutzermanagement bietet. Die Dateien /etc/passwd und /etc/shadow m&uuml;ssen mit <b>modsave</b> gespeichert werden. Bitte aktiviere die Unterst&uuml;tzung f&uuml;r normale Benutzer nur, wenn Du genau wei&szlig;t, was Du tust." en:"Please note that the FRITZ!Box does not support normal user management. The files /etc/passwd and /etc/shadow have to be saved with <b>modsave</b>. Please activate the support for regular users only if you know what you are doing.")</p>
<i>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen " en:"Additional command-line options "):</i>
<p>$(lang de:"Optionen" en:"Options"): <input type="text" name="options" size="50" maxlength="255" value="$(html "$OPENSSH_OPTIONS")"></p>
<p><input type="hidden" name="expert" value=""> $(lang de:"Standard Optionen \(nur &auml;ndern wenn man genau wei&szlig;, was man tut\)" en:"Standard options \(don't change unless you really know, what you are doing\)"):
<input type="checkbox" name="expert" value="yes" $([ "$OPENSSH_EXPERT" = yes ] && echo checked) onclick='document.getElementById("id_settings").style.display=(this.checked)? "block" : "none"'></p>
<div align="center"><textarea id="id_settings" style="width: 500px; $([ "$OPENSSH_EXPERT" = yes ] || echo display:none)" name="settings" rows="15" cols="80" wrap="off" >$OPENSSH_SETTINGS</textarea></div>
EOF
sec_end
