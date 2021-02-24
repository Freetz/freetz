#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$SUBVERSION_LOGGING" yes:log

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SUBVERSION_ENABLED" "" "" 1
sec_end

sec_begin "$(lang de:"Priorit&auml;t" en:"Priority")"
cat << EOF
<p>
<label for='nicelevel'>Nice-Level: </label>
<input type='text' id='nicelevel' name='nicelevel' size='3' maxlength='3' value="$(html "$SUBVERSION_NICELEVEL")">
</p>
EOF
sec_end

sec_begin "$(lang de:"Repository" en:"Repository")"
cat << EOF
<p>
<label for="root">$(lang de:"Pfad" en:"Path"): </label>
<input type="text" id="root" name="root" size="55" maxlength="255" value="$(html "$SUBVERSION_ROOT")">
</p>
EOF
sec_end

sec_begin "$(lang de:"Server" en:"Server")"
cat << EOF
<p>
<label for="bindaddress">$(lang de:"Bind-Adresse" en:"Bind-address"): </label>
<input type="text" id="bindaddress" name="bindaddress" value="$(html "$SUBVERSION_BINDADDRESS")">
</p>

<p>
<label for="port">$(lang de:"Port" en:"Listen-port"): </label>
<input type="text" id="port" name="port" value="$(html "$SUBVERSION_PORT")">
</p>
EOF
sec_end

sec_begin "$(lang de:"Logging" en:"Logging")"
cat << EOF
<p>
<input type="hidden" name="logging" value="no">
<input id="logging" type="checkbox" name="logging" value="yes"$log_chk><label for="logging"> $(lang de:"Log aktivieren" en:"Activate logging")</label>
</p>
<p>
<label for="logfile">$(lang de:"Logdatei" en:"Log-file"): </label>
<input type="text" id="logfile" name="logfile" size="55" maxlength="255" value="$(html "$SUBVERSION_LOGFILE")">
</p>
<br/>
<p style="font-size:10px;"><a href="$(href status subversion subversion-log)">$(lang de:"Logdatei anzeigen" en:"Show log-file")</a></p>
EOF
sec_end
