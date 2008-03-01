#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
routing_yes_chk=''; routing_no_chk=''

if [ "$PPTP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$PPTP_ROUTING" = "yes" ]; then routing_yes_chk=' checked'; else routing_no_chk=' checked'; fi

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
sec_begin 'Routing von IP-Netzen'

cat << EOF
<small style="font-size:0.8em"> <i>Hier wird das Routing zum Server-Netz konfiguriert.</i></small>
<p>
<input id="p1" type="radio" name="routing" value="yes"$routing_yes_chk><label for="p1"> Aktiviert</label>
<input id="p2" type="radio" name="routing" value="no"$routing_no_chk><label for="p2"> Deaktiviert</label>
</p>
<h2>Servernetz:</h2>
<p>Netz-IP: <input type="text" name="remote_net" size="16" maxlength="15" value="$(httpd -e "$PPTP_REMOTE_NET")">
Subnetz-Maske: <input type="text" name="remote_mask" size="16" maxlength="15" value="$(httpd -e "$PPTP_REMOTE_MASK")"></p>
EOF

sec_end
