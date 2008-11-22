#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
closed_chck=''; open_chk='';
strict_entry_chck=''; strict_exit_chck='';

if [ "$TOR_ENABLED" == "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$TOR_SOCKS_POLICY_REJECT" == "yes" ]; then closed_chck=' checked'; else open_chk=' checked'; fi
if [ "$TOR_STRICT_ENTRY_NODES" == "yes" ]; then strict_entry_chck=' checked'; fi
if [ "$TOR_STRICT_EXIT_NODES" == "yes" ]; then strict_exit_chck=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label> <input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Configuration")'

cat << EOF
<h2>$(lang de:"Der Tor Server ist gebunden an" en:"The Tor server is listening on")</h2>
<p>$(lang de:"IP Adresse" en:"IP Address"):&nbsp;<input id="address" type="text" size="16" maxlength="16" name="socks_address" value="$(html "$TOR_SOCKS_ADDRESS")">   
$(lang de:"Port" en:"Port"):&nbsp;<input id="port" type="text" size="5" maxlength="5" name="socks_port" value="$(html "$TOR_SOCKS_PORT")"></p>
<h2>$(lang de:"Fernsteuerung" en:"Remote Control") (optional)</h2>
<p>Control Port:&nbsp;<input id="control" type="text" size="5" maxlength="5" name="control_port" value="$(html "$TOR_CONTROL_PORT")"></p>
<p>$(lang de:"Zeitlimit f&uuml;r Tor-Verbindungen" en:"Circuit Idle Timeout") (optional):&nbsp;<input id="idle_timeout" type="text" size="5" maxlength="5" name="circuit_idle_timeout" value="$(html "$TOR_CIRCUIT_IDLE_TIMEOUT")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zugriffskontrolle" en:"Access Control")'

cat << EOF
<p>$(lang de:"Erlaubte Clients" en:"Allowed clients"): <input id="e4" type="radio" name="socks_policy_reject" value="no"$open_chk><label for="e4"> $(lang de:"alle" en:"all")</label> <input id="e3" type="radio" name="socks_policy_reject" value="yes"$closed_chck><label for="e3"> $(lang de:"eingeschr&auml;nkt" en:"restricted")</label></p>
<h2>$(lang de:"Liste mit IP-Adressen (eine pro Zeile)" en:"List of IP-Addresses (one per line)")</h2>
<p><textarea id="accept" name="socks_policy_accept" rows="4" cols="50" maxlength="255">$(html "$TOR_SOCKS_POLICY_ACCEPT")</textarea><br />
Syntax: &lt;addr&gt;[/&lt;mask&gt;]<br />
<span style="font-size:10px;">$(lang de:"Um alle lokal verbundenen Netzwerke zu erlauben, kann man den Alias <i>private</i> anstelle einer Adresse eintragen" en:"To specify all internal and link-local networks, you can use the <i>private</i> alias instead of an address").</span>
</p>
EOF

sec_end
sec_begin '$(lang de:"Eingangs- und Ausgangsserver" en:"Entrynodes and Exitnodes")'

cat << EOF
<h2>$(lang de:"Liste mit Tor Servern (einer pro Zeile)" en:"List of Tor servers (one per line)")</h2>
<p><textarea id="accept" name="entry_nodes" rows="4" cols="50" maxlength="255">$(html "$TOR_ENTRY_NODES")</textarea></p>
<p>$(lang de:"Nur diese Server als Eingang verwenden" en:"Only use these servers as entry nodes"): <input type="hidden" name="strict_entry_nodes" value="no"><input id="e6" type="checkbox" name="strict_entry_nodes" value="yes"$strict_entry_chck></p>
<h2>$(lang de:"Liste mit Tor Servern (einer pro Zeile)" en:"List of Tor servers (one per line)")</h2>
<p><textarea id="accept" name="exit_nodes" rows="4" cols="50" maxlength="255">$(html "$TOR_EXIT_NODES")</textarea></p>
<p>$(lang de:"Nur diese Server als Ausgang verwenden" en:"Only use these servers as exit nodes"): <input type="hidden" name="strict_exit_nodes" value="no"><input id="e7" type="checkbox" name="strict_exit_nodes" value="yes"$strict_exit_chck></p>
EOF

sec_end
