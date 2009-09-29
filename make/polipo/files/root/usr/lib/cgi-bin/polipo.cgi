#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''

case "$POLIPO_ENABLED" in yes) auto_chk=' checked';; *) man_chk=' checked';;esac

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
<input type="text" name="clients" size="75" maxlength="200" value="$(html "$POLIPO_CLIENTS")">    

<h2>$(lang de:"Andere Optionen (mit ';' getrennt)" en:"Additional options (separated by ';')"):</h2>
<p><input type="text" name="options" size="75" maxlength="255" value="$(html "$POLIPO_OPTIONS")"></p>
EOF

sec_end
