#!/bin/sh

. /usr/lib/libmodcgi.sh
. /usr/lib/libmodredir.sh

check "$POLIPO_DISABLEINDEXING" true:indexdis
check "$POLIPO_DISABLESERVERSLIST" true:serverdis
check "$POLIPO_DISABLECONFIGURATION" true:confdis
check "$POLIPO_DISABLELOCALINTERFACE" true:localifdis

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$POLIPO_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<i>Proxy-IP:</i> &nbsp; <input type="text" name="ip" size="20" maxlength="20" value="$(html "$POLIPO_IP")"> &nbsp; &nbsp; &nbsp;
<i>Proxy-Port:</i> &nbsp; <input type="text" name="port" size="10" maxlength="10" value="$(html "$POLIPO_PORT")">

<h2>Optional: $(lang de:"Liste zu&auml;ssiger Clients (mit ',' getrennt)" en:"List of allowed clients (separated by ',')"):</h2>
<input type="text" name="clients" size="68" maxlength="200" value="$(html "$POLIPO_CLIENTS")">

<table  width="100%" style="table-layout:fixed">
 <tr>
  <td style="width:50%"><input type="hidden" name="disableindexing" value="false">
<i>disableIndexing:</i> &nbsp; <input title="$(lang de:"Indizieren des lokalen Caches deaktivieren" en:"Disable indexing of the local cache")" id="id_index" type="checkbox" name="disableindexing" value="true"$indexdis_chk></td>
  <td style="width:50%"><input type="hidden" name="disableserverslist" value="false">
<i>disableServersList:</i> &nbsp; <input title="$(lang de:"Liste der bekannten Server deaktivieren" en:"Disable the list of known servers")" id="id_server" type="checkbox" name="disableserverslist" value="true"$serverdis_chk></td>
 </tr>
</table>

<h2>$(lang de:"Andere Optionen (eine pro Zeile)" en:"Additional options (one per line)"):</h2>
<p><textarea name="options" rows="5" cols="65">$(html "$POLIPO_OPTIONS")</textarea></p>
EOF

sec_end

sec_begin "$(lang de:"Polipo interne Webschnittstelle" en:"Polipo internal web interface")"

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
