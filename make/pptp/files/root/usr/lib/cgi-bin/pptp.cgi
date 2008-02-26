#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''

if [ "$PPTP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end
sec_begin 'Konfigurationsdateien'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=chap_secrets">PPP: chap-secrets bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptp_options">PPTP: options.pptp bearbeiten</a></li>
</ul>
EOF
#<li><a href="/cgi-bin/file.cgi?id=pap_secrets">PPP: pap-secrets bearbeiten</a></li>
#<li><a href="/cgi-bin/file.cgi?id=options">PPP: options bearbeiten</a></li>

sec_end
sec_begin 'pptp'

cat << EOF
<h2>Adresse des PPTP-Servers:</h2>
<p>IP/FQDN: <input type="text" name="address" size="40" maxlength="40" value="$(httpd -e "$PPTP_ADDRESS")"></p>
<h2>Benutzername fuer den PPTP-Server:</h2>
<p>Benutzer: <input type="text" name="user" size="20" maxlength="20" value="$(httpd -e "$PPTP_USER")"></p>
<h2>Server-Name fuer den PPTP-Server:</h2>
<p>Server-Name: <input type="text" name="servername" size="20" maxlength="20" value="$(httpd -e "$PPTP_SERVERNAME")"></p>
<h2>Kommandozeilen-Optionen: </h2>
<p>Optionen: <input type="text" name="options" size="20" maxlength="255" value="$(httpd -e "$PPTP_OPTIONS")"></p>
EOF

sec_end
