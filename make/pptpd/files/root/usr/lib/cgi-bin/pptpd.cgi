#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
routing_yes_chk=''; routing_no_chk=''

if [ "$PPTPD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$PPTPD_ROUTING" = "yes" ]; then routing_yes_chk=' checked'; else routing_no_chk=' checked'; fi

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
<li><a href="/cgi-bin/file.cgi?id=pptpd_options">PPTPD: options.pptpd bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptpd_conf">PPTPD: Konfiguration bearbeiten</a></li>
</ul>
EOF
#<li><a href="/cgi-bin/file.cgi?id=pap_secrets">PPP: pap-secrets bearbeiten</a></li>
#<li><a href="/cgi-bin/file.cgi?id=options">PPP: options bearbeiten</a></li>

sec_end
sec_begin 'Routing von IP-Netzen'

cat << EOF
<small style="font-size:0.8em"> <i>Hier wird das Routing zu Client-Netzen konfiguriert.</i></small>
<p>
<input id="p1" type="radio" name="routing" value="yes"$routing_yes_chk><label for="p1"> Aktiviert</label>
<input id="p2" type="radio" name="routing" value="no"$routing_no_chk><label for="p2"> Deaktiviert</label>
</p>
<h2>Netz-Routing: (eine pro Zeile)</h2>
<small style="font-size:0.8em">Syntax: &lt;Netz-IP&gt; &lt;Netz-Mask&gt; &lt;Client-IP&gt; [&lt;Kommentar&gt;]<br>
(z.B.: 192.168.1.0 255.255.255.0 192.168.178.100 Client-Netz)</small>
<p><textarea name="net_routing" rows="5" cols="59" maxlength="255">$(httpd -e "$PPTPD_NET_ROUTING")</textarea></p>
EOF

sec_end