#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
dhcp_yes_chk=''; dhcp_no_chk=''
ethers_chk=''

if [ "$DNSMASQ_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$DNSMASQ_DHCP" = "yes" ]; then dhcp_yes_chk=' checked'; else dhcp_no_chk=' checked'; fi
if [ "$DNSMASQ_ETHERS" = "yes" ]; then ethers_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"DNS Server" en:"DNS server")'

cat << EOF
<h2>$(lang de:"Der DNS Server ist gebunden an" en:"The DNS server is listening on"):</h2>
<p>Port: <input type="text" name="dns_port" size="5" maxlength="5" value="$(httpd -e "$DNSMASQ_DNS_PORT")"></p>
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
<p>$(lang de:"Optionen" en:"Options"): <input type="text" name="options" size="20" maxlength="255" value="$(httpd -e "$DNSMASQ_OPTIONS")"></p>
EOF

sec_end
sec_begin '$(lang de:"DHCP Server" en:"DHCP server")'

cat << EOF
<p>
<input id="d1" type="radio" name="dhcp" value="yes"$dhcp_yes_chk><label for="d1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="d2" type="radio" name="dhcp" value="no"$dhcp_no_chk><label for="d2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<h2>$(lang de:"DHCP Range (eine pro Zeile)" en:"DHCP range (one per line)")</h2>
<p><textarea name="dhcp_range" rows="4" cols="50" maxlength="255">$(httpd -e "$DNSMASQ_DHCP_RANGE")</textarea></p>
<p>
<input type="hidden" name="ethers" value="no">
<input id="s1" type="checkbox" name="ethers" value="yes"$ethers_chk><label for="s1"> $(lang de:"Statische DHCP Leases aus" en:"Static DHCP leases from") <a href="/cgi-bin/file.cgi?id=exhosts">Hosts</a> (MAC &lt;-&gt; IP)</label><br>
<span style="font-size:10px;">($(lang de:"nur Eintr&auml;ge, die eine g&uuml;ltige IP und MAC aufweisen" en:"items with valid IP and MAC addresses only"))</span>
</p>
EOF

sec_end
