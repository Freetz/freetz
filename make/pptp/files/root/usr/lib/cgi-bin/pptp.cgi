#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$PPTP_ROUTING" yes:routing_yes "*":routing_no
check "$PPTP_RESTART" yes:restart

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$PPTP_ENABLED" "" "" 0
sec_end

if [ "$FREETZ_REPLACE_KERNEL" != "y" ]; then
sec_begin "$(lang de:"Warnung" en:"Attention")"
cat << EOF
$(lang de:"Ohne 'replace kernel' kann mppe und mppc nicht genutzt werden." en:"Without 'replace kernel' you can not use mppe and mppc.")
EOF
sec_end
fi

sec_begin "$(lang de:"Konfigurationsdateien" en:"Configuration files")"
cat << EOF
<ul>
<li><a href="$(href file pppd chap_secrets)">PPPD: $(lang de:"chap-secrets bearbeiten" en:"edit chap-secrets")</a></li>
<li><a href="$(href file pptp options)">PPTP: $(lang de:"options.pptp bearbeiten" en:"edit options.pptp")</a></li>
</ul>
EOF
sec_end

sec_begin "$(lang de:"PPTP Konfiguration" en:"PPTP configuration")"
cat << EOF
<p>$(lang de:"Hostname/IP-Adresse" en:"Hostname/IP address"): <input type="text" name="address" size="35" maxlength="255" value="$(html "$PPTP_ADDRESS")"></p>
<p>$(lang de:"Benutzername" en:"Username"): <input type="text" name="user" size="15" maxlength="20" value="$(html "$PPTP_USER")"></p>
<p>$(lang de:"Servername" en:"Servername"): <input type="text" name="servername" size="15" maxlength="20" value="$(html "$PPTP_SERVERNAME")"></p>
EOF
sec_end

sec_begin "$(lang de:"Zus&auml;tzliche Einstellungen" en:"Additional configuration")"
cat << EOF
<p>$(lang de:"Kommandozeilen-Optionen" en:"Commandline options"): <input type="text" name="options" size="24" maxlength="255" value="$(html "$PPTP_OPTIONS")"></p>
<p><input type="hidden" name="restart" value="no">
<input id="s1" type="checkbox" name="restart" value="yes"$restart_chk><label for="s1">$(lang de:"Reconnect bei Verbindungsabbruch" en:"Reconnect on disconnect")</label></p>
<p>$(lang de:"Befehl vor Verbindungsaufbau" en:"Preconnecting command"): <input type="text" name="preconn" size="35" maxlength="255" value="$(html "$PPTP_PRECONN")"><p>
EOF
sec_end

sec_begin "$(lang de:"IP-Routing" en:"IP routing")"
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
