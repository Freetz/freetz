#!/bin/sh

# keine Schleife, wenn wir schon libmodcgi.sh hatten ;-)
[ -z "$SENDSID" ] && . /usr/lib/libmodcgi.sh

# Schicken wir dem Browser eine SessionID, gueltig fuer alle Pfade
echo "Set-Cookie: SID=$SENDSID;Path=/"

cgi_begin "$(lang de:"Anmelden" en:"Login")"

. /usr/mww/cgi-bin/md5hash.sh

cat << EOF
<br><br>
$(lang de:"Passwort" en:"Password"): <input  type="password" id="inp_pw" maxlength="45" onkeydown="if (event.keyCode == 13) document.getElementById('id_go').click()">
&nbsp;
<input type="button" name="go" id="id_go" value="$(lang de:"Anmelden" en:"Login")"
EOF
echo "onclick='location.href=\"/cgi-bin/login.cgi?hash=\"+makemd5(document.getElementById(\"inp_pw\").value, \"$SENDSID\"); '>"
echo "<script> document.getElementById(\"inp_pw\").focus(); </script>"
echo '<br><br>'

# Waren wir schonmal hier? Dann war was falsch!
[ "$WRONGPW" = 1 ] && echo "<b>$(lang de:"Passwort falsch!" en:"Wrong password!")</b>"

cgi_end

# Wir "merken" uns genau ein SID-"Angebot" 
echo "$SENDSID#$REMOTE_ADDR" > /tmp/loginsid

