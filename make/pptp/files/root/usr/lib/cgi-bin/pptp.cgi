#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
routing_yes_chk=''; routing_no_chk=''; restart_chk=''

if [ "$PPTP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$PPTP_ROUTING" = "yes" ]; then routing_yes_chk=' checked'; else routing_no_chk=' checked'; fi
if [ "$PPTP_RESTART" = "yes" ]; then restart_chk=' checked'; fi

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
<br>
<li><a href="/cgi-bin/file.cgi?id=chap_secrets">PPP: chap-secrets bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptp_options">PPTP: options.pptp bearbeiten</a></li>
EOF
#<li><a href="/cgi-bin/file.cgi?id=pap_secrets">PPP: pap-secrets bearbeiten</a></li>
#<li><a href="/cgi-bin/file.cgi?id=options">PPP: options bearbeiten</a></li>

sec_end
sec_begin 'PPTP Konfiguration'

cat << EOF
<h2>Adresse des PPTP-Servers:</h2>
IP/DDNS: <input type="text" name="address" size="43" maxlength="40" value="$(httpd -e "$PPTP_ADDRESS")"><br>
<h2>Benutzer und Servername f&uuml;r den PPTP-Server:</h2>
Benutzer: <input type="text" name="user" size="15" maxlength="20" value="$(httpd -e "$PPTP_USER")">
Server: <input type="text" name="servername" size="15" maxlength="20" value="$(httpd -e "$PPTP_SERVERNAME")"><br>
<h2>Kommandozeilen-Optionen: </h2>
Optionen: <input type="text" name="options" size="24" maxlength="255" value="$(httpd -e "$PPTP_OPTIONS")"><br><br>
<i>Extra-Einstellungen: </i>
<input type="hidden" name="restart" value="no">
<input id="s1" type="checkbox" name="restart" value="yes"$restart_chk><label for="s1">Keepalive</label>
EOF

sec_end
sec_begin 'Routing von IP-Netzen'

cat << EOF
<small style="font-size:0.8em"> <i>Hier wird das Routing zum Server-Netz konfiguriert.</i></small>
<p>
<input id="p1" type="radio" name="routing" value="yes"$routing_yes_chk><label for="p1"> Aktiviert</label>
<input id="p2" type="radio" name="routing" value="no"$routing_no_chk><label for="p2"> Deaktiviert</label>
</p>
<h2>Netz-Routing: (eine pro Zeile)</h2>
<small style="font-size:0.8em">Syntax: &lt;Netz-IP&gt; &lt;Netz-Mask&gt; [&lt;Kommentar&gt;]<br>
(z.B.: 192.168.178.0 255.255.255.0 Server-Netz)</small><br>
<textarea name="net_routing" rows="3" cols="50" maxlength="255">$(httpd -e "$PPTP_NET_ROUTING")</textarea>
EOF

sec_end