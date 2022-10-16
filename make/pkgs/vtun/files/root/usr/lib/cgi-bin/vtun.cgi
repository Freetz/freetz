#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$VTUN_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF

$(lang de:"Aufrufparamater" en:"Startparameters") <input id="id_params" size="50" type="text" name="startparams" value="$VTUN_STARTPARAMS" title="eg. configname <IP of Peer>" > <br />
$(lang de:"(z.B. Clientverbindung zum Server: <i>name 1.2.3.4</i>)" en:"(e.g. client connection to Server:  <i>name 1.2.3.4</i>)") <br />
<small style="font-size:0.8em"><b>Serverparameter:</b> <i>-s  [-P port] [-L local address]</i> <br />  <b>Clientparameter:</b> <i>[-p] [-m] [-t timeout] &lt;host profile&gt; &lt;server address&gt; </i> </small> <br />
<p>$(lang de:"Konfigurationsdatei:" en:"Configurationfile:")
<textarea id="id_config" style="width: 500px; " name="config" rows="30" cols="80" wrap="off" >$VTUN_CONFIG</textarea></p>
EOF

sec_end
