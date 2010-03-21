#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$VTUN_ENABLED" yes:auto "*":man

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

$(lang de:"Aufrufparamater" en:"Startparameters") <input id="id_params" size="50" type="text" name="startparams" value="$VTUN_STARTPARAMS" title="eg. configname <IP of Peer>" > <br />
$(lang de:"(z.B. Clientverbindung zum Server: <i>name 1.2.3.4</i>)" en:"(e.g. client connection to Server:  <i>name 1.2.3.4</i>)") <br />
<small style="font-size:0.8em"><b>Serverparameter:</b> <i>-s  [-P port] [-L local address]</i> <br />  <b>Clientparameter:</b> <i>[-p] [-m] [-t timeout] &lt;host profile&gt; &lt;server address&gt; </i> </small> <br />
<p>$(lang de:"Konfigurationsdatei:" en:"Configurationfile:")
<textarea id="id_config" style="width: 500px; " name="config" rows="30" cols="80" wrap="off" >$VTUN_CONFIG</textarea></p>
EOF

sec_end
