#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$PPTPD_ENABLED" yes:auto "*":man
check "$PPTPD_ROUTING" yes:routing_yes "*":routing_no

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
<li><a href="/cgi-bin/file.cgi?id=pptpd_options">PPTPD: $(lang de:"options.pptpd bearbeiten" en:"edit options.pptpd")</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptpd_conf">PPTPD: $(lang de:"pptpd.conf bearbeiten" en:"edit pptpd.conf")</a></li>
</ul>
EOF
#<li><a href="/cgi-bin/file.cgi?id=pap_secrets">PPP: pap-secrets bearbeiten</a></li>
#<li><a href="/cgi-bin/file.cgi?id=options">PPP: options bearbeiten</a></li>

sec_end
sec_begin '$(lang de:"IP-Routing" en:"IP routing")'

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
