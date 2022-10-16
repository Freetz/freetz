#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$PPTPD_ROUTING" yes:routing_yes "*":routing_no

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$PPTPD_ENABLED" "" "" 0
sec_end

if [ "$FREETZ_REPLACE_KERNEL" != "y" ]; then
sec_begin "$(lang de:"Warnung" en:"Attention")"
cat << EOF
$(lang de:"Ohne 'replace kernel' kann mppe und mppc nicht genutzt werden." en:"Without 'replace kernel' you can not use mppe and mppc.")
EOF
sec_end
fi

sec_begin "$(lang de:"Weitere Konfigurationsdateien" en:"Other configuration files")"
cat << EOF
<ul>
<li><a href="$(href file pppd chap_secrets)">PPPD: $(lang de:"chap-secrets bearbeiten" en:"edit chap-secrets")</a></li>
EOF
if [ "$FREETZ_PACKAGE_PPPD_WITH_EAPTLS" == "y" ]; then
cat << EOF
<li><a href="$(href file pppd eaptls_server)">PPPD: $(lang de:"eaptls-server bearbeiten" en:"edit eaptls-server")</a></li>
EOF
fi
cat << EOF
</ul>
EOF
sec_end

sec_begin "$(lang de:"IP-Routing" en:"IP routing")"
cat << EOF
<small style="font-size:0.8em"> <i>$(lang de:"Hier wird das Routing zu Client-Netzen konfiguriert." en:"Here you can configure the routing to client subnets.")</i></small>
<p>
<input id="p1" type="radio" name="routing" value="yes"$routing_yes_chk><label for="p1"> $(lang de:"Aktiviert" en:"Activated")</label>
<input id="p2" type="radio" name="routing" value="no"$routing_no_chk><label for="p2"> $(lang de:"Deaktiviert" en:"Deactivated")</label>
</p>
<h2>$(lang de:"Netz-Routing: (eines pro Zeile)" en:"Subnet routing (one per row)")</h2>
<small style="font-size:0.8em">$(lang de:"Syntax: &lt;Netz-IP&gt; &lt;Netz-Mask&gt; &lt;Client-IP&gt; [&lt;Kommentar&gt;]" en:"Syntax: &lt;Subnet-IP&gt; &lt;Subnetmask&gt; &lt;Client-IP&gt; [&lt;Comment&gt;]")<br>
($(lang de:"z.B." en:"example"): 192.168.1.0 255.255.255.0 192.168.178.100 $(lang de:"Client-Netz" en:"client_subnet"))</small>
<p><textarea name="net_routing" rows="5" cols="59" maxlength="255">$(html "$PPTPD_NET_ROUTING")</textarea></p>
EOF
sec_end
