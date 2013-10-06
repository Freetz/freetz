#!/bin/sh


. /usr/lib/libmodcgi.sh
. /usr/lib/libmodredir.sh

check "$POLIPO_ENABLED" yes:auto "*":man
check "$POLIPO_DISABLEINDEXING" true:indexdis
check "$POLIPO_DISABLESERVERSLIST" true:serverdis
check "$POLIPO_DISABLECONFIGURATION" true:confdis
check "$POLIPO_DISABLELOCALINTERFACE" true:localifdis

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<i>Proxy-IP:</i> &nbsp; <input type="text" name="ip" size="20" maxlength="20" value="$(html "$POLIPO_IP")"> &nbsp; &nbsp; &nbsp;
<i>Proxy-Port:</i> &nbsp; <input type="text" name="port" size="10" maxlength="10" value="$(html "$POLIPO_PORT")">

<h2>Optional: $(lang de:"Liste zu&auml;ssiger Clients" en:"List of allowed clients"):</h2>
<input type="text" name="clients" size="68" maxlength="200" value="$(html "$POLIPO_CLIENTS")">

<table  width="100%" style="table-layout:fixed">
 <tr>
  <td style="width:50%"><input type="hidden" name="disableindexing" value="false">
<i>disableIndexing:</i> &nbsp; <input title="$(lang de:"Indizieren des lokalen Caches deaktivieren" en:"Disable indexing of the local cache")" id="id_index" type="checkbox" name="disableindexing" value="true"$indexdis_chk></td>
  <td style="width:50%"><input type="hidden" name="disableserverslist" value="false">
<i>disableServersList:</i> &nbsp; <input title="$(lang de:"Liste der bekannten Server deaktivieren" en:"Disable the list of known servers")" id="id_server" type="checkbox" name="disableserverslist" value="true"$serverdis_chk></td>
 </tr>
</table>


<h2>$(lang de:"Andere Optionen (mit ';' getrennt)" en:"Additional options (separated by ';')"):</h2>
<p><input type="text" name="options" size="68" maxlength="255" value="$(html "$POLIPO_OPTIONS")"></p>

EOF

sec_end

sec_begin '$(lang de:"Polipo interne Webschnittstelle" en:"Polipo internal web interface")'

cat << EOF
<table  width="100%" style="table-layout:fixed">
 <tr>
  <td style="width:50%"><input type="hidden" name="disableconfiguration" value="false">
<i>disableConfiguration:</i> &nbsp; <input title="$(lang de:"Konfiguration zur Laufzeit deaktivieren" en:"Disable reconfiguring Polipo at runtime")" id="id_config" type="checkbox" name="disableconfiguration" value="true"$confdis_chk></td>
  <td style="width:50%"><input type="hidden" name="disablelocalinterface" value="false">
<i>disableLocalInterface:</i> &nbsp; <input title="$(lang de:"Lokale Konfigurationsseiten von Polipo deaktivieren" en:"Disable the local configuration pages")" id="id_config" type="checkbox" name="disablelocalinterface" value="true"$localifdis_chk></td>
 </tr>
</table>
EOF
if [ "running" == "$(/mod/etc/init.d/rc.polipo status)" ] && [ "true" != "$POLIPO_DISABLELOCALINTERFACE" ]; then
	echo "<p><a href=http://$(self_host):$(html "$POLIPO_PORT")/polipo/ target=_ >Link $(lang de:"zur" en:"to") Polipo GUI</a></p>"
fi

sec_end

