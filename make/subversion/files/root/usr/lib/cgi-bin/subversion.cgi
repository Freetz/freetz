#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; inetd_chk=''
case "$SUBVERSION_ENABLED" in yes) auto_chk=' checked';; inetd) inetd_chk=' checked';; *) man_chk=' checked';; esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="auto" type="radio" name="enabled" value="yes"$auto_chk><label for="auto"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="manual" type="radio" name="enabled" value="no"$man_chk><label for="manual"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if [ -e "/etc/default.inetd/inetd.cfg" ]; then
cat << EOF
<input id="inetd" type="radio" name="enabled" value="inetd"$inetd_chk><label for="inetd"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF
sec_end

sec_begin '$(lang de:"Repository" en:"Repository")'
cat << EOF
<p>
<label for="svnroot">$(lang de:"Pfad" en:"Path"): </label>
<input type="text" id="svnroot" name="svnroot" size="55" maxlength="255" value="$(html "$SUBVERSION_ROOT")">
</p>
EOF
sec_end

sec_begin '$(lang de:"Server" en:"Server")'
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
