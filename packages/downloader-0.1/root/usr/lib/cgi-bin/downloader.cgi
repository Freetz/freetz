#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; ftp_chk='' ; http_chk=''

if [ "$DOWNLOADER_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$DOWNLOADER_SRVPRFX" = "ftp://" ]; then ftp_chk=' selected'; else http_chk=' selected'; fi

sec_begin '$(lang de:"Aktivierung" en:"Activation")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Aktiv" en:"Active")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Inaktiv" en:"Inactive")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Serverparameter" en:"Server parameters")'

cat << EOF
<table>
<tr>
<td>$(lang de:"Servertyp" en:"Server type"):</td><td>&nbsp;&nbsp;&nbsp;&nbsp;URL:</td><td>&nbsp;&nbsp;$(lang de:"Entferntes Verzeichnis" en:"Remote dir"):</td>
</tr>
<tr>
<td>&nbsp;&nbsp;<i>http://</i></td><td><i>&nbsp;&nbsp;&nbsp;&nbsp;meinserver.de</i></td><td><i>&nbsp;&nbsp;/fritzbox/kernel26</i></td>
</tr>
<tr>
<td>
<select name="srvprfx" id="srvprfx">
<option title="FTP"
value="ftp://"$ftp_chk>ftp://</option>
<option title="HTTP"
value="http://"$http_chk>http://</option>
</select>
</td>
<td>
<input type="text" name="srvurl" size="30" maxlength="30" value="$(httpd -e "$DOWNLOADER_SRVURL")">
</td>
<td>
<input type="text" name="srvdir" size="30" maxlength="30" value="$(httpd -e "$DOWNLOADER_SRVDIR")">
</td>
</tr>
</table>
<h2>$(lang de:"Nur für FTP-Server" en:"Only for ftp server"):</h2>
<p>$(lang de:"Benutzer" en:"User"):
<input type="text" name="srvusr" size="20" maxlength="30" value="$(httpd -e "$DOWNLOADER_SRVUSR")">
&nbsp;&nbsp;&nbsp;&nbsp;Passwor$(lang de:"t" en:"d"):
<input type="text" name="srvpwd" size="20" maxlength="30" value="$(httpd -e "$DOWNLOADER_SRVPWD")">
</p>
EOF
sec_end
sec_begin '$(lang de:"Downloadparameter" en:"Download parameters")'

cat << EOF
<p>$(lang de:"Wartezeit" en:"Duration"):
<input type="text" name="twait" size="5" maxlength="5" value="$(httpd -e "$DOWNLOADER_TWAIT")">
&nbsp;Sek. &nbsp;&nbsp;&nbsp;$(lang de:"Wiederholversuche" en:"Number of repeats"):
<input type="text" name="nrep" size="5" maxlength="5" value="$(httpd -e "$DOWNLOADER_NREP")">
</p>
EOF

sec_end
sec_begin '$(lang de:"Dateien zum Downloaden" en:"Download files")'

cat << EOF
<table>
<tr>
<td style="font-size:10pt;"><b>Syntax:</b></td><td style="font-size:10pt;">&lt;$(lang de:"Datei(ohne.gz)" en:"File(w/o.gz)")&gt;</td><td style="font-size:10pt;">&lt;$(lang de:"Attribute" en:"Permissions")&gt;</td><td style="font-size:10pt;">&lt;$(lang de:"Zielverzeichnis" en:"Destination dir")&gt;</td>
</tr>
<tr>
<td style="font-size:10pt;"><b>$(lang de:"Beispiel" en:"Example"):</b></td><td style="font-size:10pt;">dropbear</td><td style="font-size:10pt;">755</td><td style="font-size:10pt;">/mod/bin</td>
</tr>
</table>
<p><textarea name="files" rows="4" cols="50" maxlength="255">$(httpd -e "$DOWNLOADER_FILES")</textarea></p>
EOF

sec_end
