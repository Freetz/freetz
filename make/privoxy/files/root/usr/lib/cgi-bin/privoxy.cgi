#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
toggle_chk=''; neutral_chk='';

if [ "$PRIVOXY_ENABLED" == "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$PRIVOXY_TOGGLE" == "1" ]; then toggle_chk=' checked'; else neutral_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label> <input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Configuration")'

cat << EOF
<h2>$(lang de:"Der Privoxy Server ist gebunden an" en:"The Privoxy server is listening on")</h2>
<p>$(lang de:"IP Adresse" en:"IP Address"):&nbsp;<input id="address" type="text" size="16" maxlength="16" name="listen_address" value="$(html "$PRIVOXY_LISTEN_ADDRESS")">   
$(lang de:"Port" en:"Port"):&nbsp;<input id="port" type="text" size="5" maxlength="5" name="listen_port" value="$(html "$PRIVOXY_LISTEN_PORT")"></p>
EOF

sec_end
sec_begin '$(lang de:"Filter" en:"Content Filter")'

cat << EOF
<h2>$(lang de:"Privoxy soll Inhalte beim Surfen filtern" en:"Privoxy shall filter internet content")</h2>
<p><input id="e3" type="radio" name="toggle" value="1"$toggle_chk><label for="e3"> $(lang de:"Ja" en:"Yes")</label> <input id="e4" type="radio" name="toggle" value="0"$neutral_chk><label for="e4"> $(lang de:"Nein" en:"No")</label><br />
<ul>
<li><a href="/cgi-bin/file.cgi?id=user_filter">$(lang de:"Eigene Filter bearbeiten" en:"Edit custom filter")</a></li>
<li><a href="/cgi-bin/file.cgi?id=user_action">$(lang de:"Eigene Aktionen bearbeiten" en:"Edit custom actions")</a></li>
</ul>
EOF

sec_end
sec_begin '$(lang de:"Weiterleitung" en:"Forwarding") (optional)'

cat << EOF
<h2>$(lang de:"Privoxy soll Anfragen weiterleiten an" en:"Privoxy shall forward requests to")</h2>
<p><input id="socks" type="text" size="21" maxlength="21" name="forward_socks" value="$(html "$PRIVOXY_FORWARD_SOCKS")">
<br />Syntax: &lt;ip&gt;:&lt;port&gt;</p>
EOF

sec_end
sec_begin '$(lang de:"Zugriffskontrolle" en:"Access Control") (optional)'

cat << EOF
<p>$(lang de:"Lies das Privoxy Benutzerhandbuch zum Thema <a href='http://www.privoxy.org/user-manual/config.html#ACCESS-CONTROL' target='_blank'>Zugriffskontrolle</a> f&uuml;r eine detailierte Beschreibung." en:"See the Privoxy User Manual about <a href='http://www.privoxy.org/user-manual/config.html#ACCESS-CONTROL' target='_blank'>Access Control</a> for a brief description.")</p>
<h2>$(lang de:"Liste erlaubter Clients und Ziele" en:"List of allowed clients and destinations")</h2>
<p><textarea id="permit" name="permit_access" rows="4" cols="50" maxlength="255">$(html "$PRIVOXY_PERMIT_ACCESS")</textarea><br />
Syntax: &lt;src_addr&gt;[/&lt;mask&gt;] [&lt;dest_addr&gt;[/&lt;mask&gt;]]</p>
<h2>$(lang de:"Liste verbotener Clients und Ziele" en:"List of denied clients and destinations")</h2>
<p><textarea id="deny" name="deny_access" rows="4" cols="50" maxlength="255">$(html "$PRIVOXY_DENY_ACCESS")</textarea><br />
Syntax: &lt;src_addr&gt;[/&lt;mask&gt;] [&lt;dest_addr&gt;[/&lt;mask&gt;]]</p>
EOF

sec_end
