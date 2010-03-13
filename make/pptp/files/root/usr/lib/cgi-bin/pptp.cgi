#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
routing_yes_chk=''; routing_no_chk=''; restart_chk=''

if [ "$PPTP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$PPTP_ROUTING" = "yes" ]; then routing_yes_chk=' checked'; else routing_no_chk=' checked'; fi
if [ "$PPTP_RESTART" = "yes" ]; then restart_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Konfigurationsdateien" en:"Configuration files")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=chap_secrets">PPPD: $(lang de:"chap-secrets bearbeiten" en:"edit chap-secrets")</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptp_options">PPTP: $(lang de:"options.pptp bearbeiten" en:"edit options.pptp")</a></li>
</ul>
EOF
#<li><a href="/cgi-bin/file.cgi?id=pap_secrets">PPP: pap-secrets bearbeiten</a></li>
#<li><a href="/cgi-bin/file.cgi?id=options">PPP: options bearbeiten</a></li>

sec_end
sec_begin '$(lang de:"PPTP Konfiguration" en:"PPTP configuration")'

cat << EOF
<p>$(lang de:"Hostname/IP-Adresse" en:"Hostname/IP address"): <input type="text" name="address" size="35" maxlength="255" value="$(html "$PPTP_ADDRESS")"></p>
<p>$(lang de:"Benutzername" en:"Username"): <input type="text" name="user" size="15" maxlength="20" value="$(html "$PPTP_USER")"></p>
<p>$(lang de:"Servername" en:"Servername"): <input type="text" name="servername" size="15" maxlength="20" value="$(html "$PPTP_SERVERNAME")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zus&auml;tzliche Einstellungen" en:"Additional configuration")'

cat << EOF
<p>$(lang de:"Kommandozeilen-Optionen" en:"Commandline options"): <input type="text" name="options" size="24" maxlength="255" value="$(html "$PPTP_OPTIONS")"></p>
<p><input type="hidden" name="restart" value="no">
<input id="s1" type="checkbox" name="restart" value="yes"$restart_chk><label for="s1">$(lang de:"Reconnect bei Verbindungsabbruch" en:"Reconnect on disconnect")</label></p>
<p>$(lang de:"Befehl vor Verbindungsaufbau" en:"Preconnecting command"): <input type="text" name="preconn" size="35" maxlength="255" value="$(html "$PPTP_PRECONN")"><p>
EOF

sec_end
sec_begin '$(lang de:"IP-Routing" en:"IP routing")'

cat << EOF
<small style="font-size:0.8em"> <i>$(lang de:"Hier wird das Routing zum Server-Netz konfiguriert." en:"Here you can configure the routing to the server subnet.")</i></small>
<p>
<input id="p1" type="radio" name="routing" value="yes"$routing_yes_chk><label for="p1"> $(lang de:"Aktiviert" en:"Activated")</label>
<input id="p2" type="radio" name="routing" value="no"$routing_no_chk><label for="p2"> $(lang de:"Deaktiviert" en:"Deactivated")</label>
</p>
<h2>$(lang de:"Netz-Routing: (eines pro Zeile)" en:"Subnet routing (one per row)")</h2>
<small style="font-size:0.8em">$(lang de:"Syntax: &lt;Netz-IP&gt; &lt;Netz-Mask&gt; [&lt;Kommentar&gt;]" en:"Syntax: &lt;Subnet-IP&gt; &lt;Subnetmask&gt; [&lt;Comment&gt;]")<br>
($(lang de:"z.B." en:"example"): 192.168.178.0 255.255.255.0 $(lang de:"Server-Netz" en:"server_subnet"))</small><br>
<textarea name="net_routing" rows="3" cols="50" maxlength="255">$(html "$PPTP_NET_ROUTING")</textarea>
EOF

sec_end
