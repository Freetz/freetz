#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; if [ "$TRANSMISSION_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
noencryption_sel=''; preferencryption_sel=''; requireencryption_sel='';
if [ "$TRANSMISSION_PEERENCRYPTIONMODE" = "ENCRYPTION_REQUIRED" ]; then
	requireencryption_sel=' selected'
elif [ "$TRANSMISSION_PEERENCRYPTIONMODE" = "ENCRYPTION_PREFERRED" ]; then
	preferencryption_sel=' selected'
else
	noencryption_sel=' selected'
fi
blocklist_chk=''; if [ "$TRANSMISSION_USEBLOCKLIST" = "yes" ]; then blocklist_chk=' checked'; fi


sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<label for='auto'>$(lang de:"Automatisch" en:"Automatic")</label>
<input id='auto' type='radio' name='enabled' value='yes'$auto_chk>

<label for='manual'>$(lang de:"Manuell" en:"Manual")</label>
<input id='manual' type='radio' name='enabled' value='no'$man_chk>
</p>

EOF

sec_end


sec_begin '$(lang de:"Arbeitsverzeichnisse" en:"Working Directories")'

cat << EOF
<p>
<label for='basedir'>$(lang de:"Basisverzeichnis" en:"Base-Directory"): </label>
<input type='text' id='basedir' name='basedir' size='50' maxlength='255' value="$(html "$TRANSMISSION_BASEDIR")">
</p>

<p>
<label for='configdir'>$(lang de:"Konfigurationsverzeichnis" en:"Configuration-Directory"): </label>
<input type='text' id='configdir' name='configdir' size='40' maxlength='255' value="$(html "$TRANSMISSION_CONFIGDIR")">
</p>

<p>
<label for='downloaddir'>$(lang de:"Download-Verzeichnis" en:"Download-Directory"): </label>
<input type='text' id='downloaddir' name='downloaddir' size='40' maxlength='255' value="$(html "$TRANSMISSION_DOWNLOADDIR")"><br />
</p>

<small>$(lang
de:"Beim Konfigurations- und Download-Verzeichnis d&uuml;rfen sowohl absolute als auch relative Pfade angegeben werden. Die relativen Pfade werden dabei als relativ zum Basisverzeichnis verstanden."
en:"Both absolute and relative paths are allowed for config- and download-directories. The relative ones will be interpreted as being relative to the base-directory."
)</small>
<br />
EOF

sec_end


sec_begin '$(lang de:"Peer-Einstellungen" en:"Peer-Settings")'

cat << EOF
<small>$(lang
de:"Es ist die Aufgabe des Users, diesen Port nach au&szlig;en zu &ouml;ffnen. Dazu kann z.B. das Freetz-Paket AVM-Firewall verwendet werden."
en:"Don't forget to open this port. Use the freetz' package AVM-Firewall for this purpose."
)</small>
<p>
<label for='peerport'>Peer-Port: </label>
<input type='text' id='peerport' name='peerport' value="$(html "$TRANSMISSION_PEERPORT")">
</p>

<p>
<label for='globalpeerlimit'>$(lang de:"Maximale Gesamtanzahl der Peers" en:"Maximum overall number of peers") </label>
<input type='text' id='globalpeerlimit' name='globalpeerlimit' value="$(html "$TRANSMISSION_GLOBALPEERLIMIT")">
</p>

<p>
<label for='torrentpeerlimit'>$(lang de:"Maximale Anzahl der Peers pro Torrent" en:"Maximum number of peers per torrent") </label>
<input type='text' id='torrentpeerlimit' name='torrentpeerlimit' value="$(html "$TRANSMISSION_TORRENTPEERLIMIT")">
</p>

<p>
<label for='peerencryptionmode'>$(lang de:"Verschl&uuml;sselungsmodus" en:"Encryption Mode")</label>
<select name='peerencryptionmode' id='peerencryptionmode'>
<option value='NO_ENCRYPTION'$noencryption_sel>$(lang de:"Keine Verschl&uuml;sselung" en:"No encryption")</option>
<option value='ENCRYPTION_PREFERRED'$preferencryption_sel>$(lang de:"Verschl&uuml;sselte Peer-Verbindungen bevorzugen" en:"Prefer encrypted peer connections")</option>
<option value='ENCRYPTION_REQUIRED'$requireencryption_sel>$(lang de:"Alle Peer-Verbindungen verschl&uuml;sseln" en:"Encrypt all peer connections")</option>
</select>
</p>

<p>
<label for='useblocklist'>$(lang de:"Peer-Blockliste verwenden" en:"Use peer-blocklist") </label>
<input type='checkbox' id='useblocklist' name='useblocklist' value='yes'$blocklist_chk>
</p>
EOF

sec_end


sec_begin '$(lang de:"RPC- und Webinterface-Einstellungen" en:"RPC and Web Interface Settings")'

cat << EOF
<small>$(lang
de:"Ist kein Passwortschutz gew&uuml;nscht, so sollen Benutzername und Kennwort leer gelassen werden."
en:"Leave user name and password empty if no password protection required."
)</small>
<p>
<label for='rpcport'>$(lang de:"RPC- und Webinterface-Port" en:"RPC- and Web-Interface-Port"): </label>
<input type='text' id='rpcport' name='rpcport' value="$(html "$TRANSMISSION_RPCPORT")">
</p>

<p>
<label for='rpcusername'>$(lang de:"Benutzername" en:"User Name"): </label>
<input type='text' id='rpcusername' name='rpcusername' value="$(html "$TRANSMISSION_RPCUSERNAME")">
</p>

<p>
<label for='rpcpassword'>$(lang de:"Kennwort" en:"Password"): </label>
<input type='text' id='rpcpassword' name='rpcpassword' value="$(html "$TRANSMISSION_RPCPASSWORD")">
<p>

<p>
<label for='rpcwhitelist'>$(lang de:"Erlaubte IP-Adressen" en:"Allowed IP-Addresses"): </label>
<input type='text' id='rpcwhitelist' name='rpcwhitelist' size='40' maxlength='255' value="$(html "$TRANSMISSION_RPCWHITELIST")">
</p>

<p>
<label for='webdir'>$(lang de:"Web-Home Verzeichnis" en:"Web-Home Directory"): </label>
<input disabled type='text' id='webdir' size='40' maxlength='255' value="$(html "$TRANSMISSION_WEBDIR")">
</p>
EOF

sec_end
