#!/bin/sh

# keine Schleife, wenn wir schon libmodcgi.sh hatten ;-)
[ -z "$SENDSID" ] && . /usr/lib/libmodcgi.sh

# Schicken wir dem Browser eine SessionID, gueltig fuer alle Pfade
echo "Set-Cookie: SID=$SENDSID;Path=/"

cgi_begin 'login'
# Waren wir schonmal hier? Dann war was falsch!
[ "$WRONGPW" ] && echo "<b>$(lang de:"Passwort falsch!" en:"Wrong password!")</b><p>"

. /usr/mww/cgi-bin/md5hash.sh

cat << 'EOF'
$(lang de:"Passwort" en:"Password"): <input  type="password" id="inp_pw" maxlength="45"  onkeydown="if (event.keyCode == 13) document.getElementById('id_go').click()">
                                   
<input type="button" name="go" id="id_go" value="$(lang de:"Anmelden" en:"Login")"
EOF
echo -n "onclick='location.href=\"/cgi-bin/login.cgi?hash=\"+makemd5(document.getElementById(\"inp_pw\").value, \"$SENDSID\"); '>"

cgi_end

# Wir "merken" uns genau ein SID-"Angebot" 
echo "$SENDSID#$REMOTE_ADDR" > /tmp/loginsid

