#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$HP_UTILS_ENABLED" "" "" 1
sec_end

sec_begin "$(lang de:"Drucker" en:"Printer")"

cat << EOF
<p>URI: <input type="text" name="uri" size="60" maxlength="255" value="$(html "$HP_UTILS_URI")"></p>
EOF

sec_end
sec_begin "$(lang de:"hp-utils-Interface" en:"hp-utils interface")"

cat << EOF
<h2>$(lang de:"Port des hp-utils-Webservers" en:"Port of hp-utils webserver"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$HP_UTILS_PORT")"></p>
EOF

sec_end
sec_begin "$(lang de:"Zugriff" en:"Access")"

cat << EOF
<p>$(lang de:"Benutzer" en:"User"): <input type="text" name="user" size="20" maxlength="255" value="$(html "$HP_UTILS_USER")"></p>
<p>$(lang de:"Passwort" en:"Password"): <input type="password" name="plain_passwd" size="20" maxlength="255" value="$(html "$HP_UTILS_PLAIN_PASSWD")"></p>
EOF

sec_end
