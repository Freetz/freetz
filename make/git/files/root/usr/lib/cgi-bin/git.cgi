#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$GIT_ENABLED" "" "" 1
sec_end

sec_begin "$(lang de:"Priorit&auml;t" en:"Priority")"
cat << EOF
<p>
<label for='nicelevel'>Nice-Level: </label>
<input type='text' id='nicelevel' name='nicelevel' size='3' maxlength='3' value="$(html "$GIT_NICELEVEL")">
</p>
EOF
sec_end

sec_begin "$(lang de:"Repository" en:"Repository")"
cat << EOF
<p>
<label for="root">$(lang de:"Pfad" en:"Path"): </label>
<input type="text" id="root" name="root" size="55" maxlength="255" value="$(html "$GIT_ROOT")">
</p>
EOF
sec_end

sec_begin "$(lang de:"Server" en:"Server")"
cat << EOF
<p>
<label for="bindaddress">$(lang de:"Bind-Adresse" en:"Bind-address"): </label>
<input type="text" id="bindaddress" name="bindaddress" value="$(html "$GIT_BINDADDRESS")">
</p>

<p>
<label for="port">$(lang de:"Port" en:"Listen-port"): </label>
<input type="text" id="port" name="port" value="$(html "$GIT_PORT")">
</p>
EOF
sec_end
