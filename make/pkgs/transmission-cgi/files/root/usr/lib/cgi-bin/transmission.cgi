#!/bin/sh

. /usr/lib/libmodcgi.sh

select "$TRANSMISSION_LOGLEVEL" info:loginfo debug:logdebug "*":logerror
select "$TRANSMISSION_PEERENCRYPTIONMODE" \
	ENCRYPTION_REQUIRED:requireencryption \
	ENCRYPTION_PREFERRED:preferencryption \
	"*":noencryption
check "$TRANSMISSION_USEBLOCKLIST" yes:useblocklist
check "$TRANSMISSION_USEDHT" yes:usedht
check "$TRANSMISSION_USEUTP" yes:useutp


sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$TRANSMISSION_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Priorit&auml;t" en:"Priority")"

cat << EOF
<p>
<label for='nice'>Nice-Level: </label>
<input type='text' id='nice' name='nice' size='3' maxlength='3' value="$(html "$TRANSMISSION_NICE")">
</p>

EOF

sec_end

sec_begin "$(lang de:"Logging" en:"Logging")"

cat << EOF
<p>
<label for='loglevel'>Log-Level: </label>
<select name='loglevel' id='loglevel'>
<option value='error'$logerror_sel>ERROR</option>
<option value='info'$loginfo_sel>INFO</option>
<option value='debug'$logdebug_sel>DEBUG</option>
</select>
</p>

EOF

sec_end

sec_begin "$(lang de:"Arbeitsverzeichnisse" en:"Working Directories")"

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

<p>
<small>$(lang
de:"Alle folgenden Verzeichnisse sind optional"
en:"Following directories can be empty"
)</small>
</p>

<p>
<small>$(lang
de:"Starte Torrents in diesem Verzeichnis automatisch:"
en:"Directory to watch for new torrents and to automatically start them:"
)</small>
</p>

<p>
<label for='watchdir'>$(lang de:"Autostart-Verzeichnis" en:"Watch-Directory"): </label>
<input type='text' id='watchdir' name='watchdir' size='40' maxlength='255' value="$(html "$TRANSMISSION_WATCHDIR")">
</p>

<p>
<small>$(lang
de:"Noch nicht fertig geladene Dateien werden in diesem Verzeichnis abgelegt:"
en:"Directory to store new torrents until they're complete:"
)</small>
</p>

<p>
<label for='incompletedir'>$(lang de:"Incomplete-Verzeichnis" en:"Incomplete-Directory"): </label>
<input type='text' id='incompletedir' name='incompletedir' size='40' maxlength='255' value="$(html "$TRANSMISSION_INCOMPLETEDIR")"><br />
</p>

<p>
<small>$(lang
de:"Verschiebe komplett fertige Dateien (gedownloaded und geseedet) in folgendes Verzeichnis:"
en:"Completely seeded downloads will be moved to the following directory:"
)</small>
</p>

<p>
<label for='finishdir'>$(lang de:"End-Verzeichnis" en:"Finish-Directory"): </label>
<input type='text' id='finishdir' name='finishdir' size='40' maxlength='255' value="$(html "$TRANSMISSION_FINISHDIR")"><br />
</p>

<p>
<small>$(lang
de:"Au&szlig;er beim Basisverzeichnis d&uuml;rfen auch relative Pfade angegeben werden. Die relativen Pfade werden dabei als relativ zum Basisverzeichnis verstanden."
en:"Both absolute and relative paths are allowed for directories except for the base-directory. The relative ones will be interpreted as being relative to the base-directory."
)</small>
</p>
EOF

sec_end


sec_begin "$(lang de:"Peer-Einstellungen" en:"Peer-Settings")"

cat << EOF
<small>$(lang
de:"Dieser Port muss selbst freigegeben werden."
en:"Don't forget to open this port."
)</small>
<p>
<label for='peerport'>Peer-Port: </label>
<input type='text' id='peerport' name='peerport' value="$(html "$TRANSMISSION_PEERPORT")">
</p>

<small>$(lang
de:"Beim Erreichen der Ratio werden Uploads automatisch gestoppt und in das End-Verzeichnis verschoben (falls angegeben)"
en:"Seeding torrents will be stopped when they reach this ratio and moved to the finish-directory (if not empty)"
)</small>

<p>
<label for='ratio'>$(lang de:"Ratio:" en:"Ratio:") </label>
<input type='text' id='ratio' name='ratio' value="$(html "$TRANSMISSION_RATIO")">
</p>

<p>
<label for='globalpeerlimit'>$(lang de:"Maximale Gesamtanzahl an Peers:" en:"Maximum overall number of peers:") </label>
<input type='text' id='globalpeerlimit' name='globalpeerlimit' value="$(html "$TRANSMISSION_GLOBALPEERLIMIT")">
</p>

<p>
<label for='torrentpeerlimit'>$(lang de:"Maximale Anzahl an Peers pro Torrent:" en:"Maximum number of peers per torrent:") </label>
<input type='text' id='torrentpeerlimit' name='torrentpeerlimit' value="$(html "$TRANSMISSION_TORRENTPEERLIMIT")">
</p>

<p>
<label for='peerencryptionmode'>$(lang de:"Verschl&uuml;sselungsmodus:" en:"Encryption mode:")</label>
<select name='peerencryptionmode' id='peerencryptionmode'>
<option value='NO_ENCRYPTION'$noencryption_sel>$(lang de:"Keine Verschl&uuml;sselung" en:"No encryption")</option>
<option value='ENCRYPTION_PREFERRED'$preferencryption_sel>$(lang de:"Verschl&uuml;sselte Peer-Verbindungen bevorzugen" en:"Prefer encrypted peer connections")</option>
<option value='ENCRYPTION_REQUIRED'$requireencryption_sel>$(lang de:"Alle Peer-Verbindungen verschl&uuml;sseln" en:"Encrypt all peer connections")</option>
</select>
</p>

<p>
<label for='useblocklist'>$(lang de:"Peer-Blockliste verwenden:" en:"Use peer-blocklist:") </label>
<input type="hidden" name="useblocklist" value="no">
<input type='checkbox' id='useblocklist' name='useblocklist' value='yes'$useblocklist_chk>
</p>

<p>
<label for='usedht'>$(lang de:"DHT verwenden:" en:"Use DHT:") </label>
<input type="hidden" name="usedht" value="no">
<input type='checkbox' id='usedht' name='usedht' value='yes'$usedht_chk>
</p>

<p>
<label for='useutp'>$(lang de:"&mu;TP verwenden:" en:"Use &mu;TP:") </label>
<input type="hidden" name="useutp" value="no">
<input type='checkbox' id='useutp' name='useutp' value='yes'$useutp_chk>
</p>
EOF

sec_end


sec_begin "$(lang de:"RPC- und Webinterface-Einstellungen" en:"RPC and Web Interface Settings")"

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
<input type='password' id='rpcpassword' name='rpcpassword' value="$(html "$TRANSMISSION_RPCPASSWORD")">
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
