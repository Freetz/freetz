#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; inetd_chk=''
anonym_chk='';users_enabled_chk='';chroot_chk='';root_chk=''

case "$VSFTPD_ENABLED" in yes) auto_chk=' checked';; inetd) inetd_chk=' checked';; *) man_chk=' checked';;esac
if [ "$VSFTPD_ANONYMOUS" = "yes" ]; then anonym_chk=' checked'; fi
if [ "$VSFTPD_USERS_ENABLED" = "yes" ]; then users_enabled_chk=' checked'; fi
if [ "$VSFTPD_CHROOT" = "yes" ]; then chroot_chk=' checked'; fi
if [ "$VSFTPD_ALLOW_ROOT" = "yes" ]; then root_chk=' checked'; fi


sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if [ -e "/etc/default.inetd/inetd.cfg" ]; then
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"FTP Server" en:"FTP server")'

cat << EOF
<h2>$(lang de:"Der FTP Server ist gebunden an" en:"The FTP server is listening on"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(httpd -e "$VSFTPD_PORT")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zugriff" en:"Access")'

cat << EOF
<p style="font-size:10px;">$(lang de:"Das Passwort f&uuml;r den Benutzer 'ftp' kann mit dem Kommando 'modpasswd ftp' festgelegt werden." en:"The password for the user 'ftp' can be set by using the command 'modpasswd ftp'.")</p>
<p>
<input type="hidden" name="anonymous" value="no">
<input id="a1" type="checkbox" name="anonymous" value="yes"$anonym_chk><label for="a1"> $(lang de:"Anonymes FTP" en:"Anonymous FTP")</label>
<input type="hidden" name="users_enabled" value="no">
<input id="a2" type="checkbox" name="users_enabled" value="yes"$users_enabled_chk><label for="a2"> $(lang de:"Lokale Benutzer" en:"Local users")</label>
<input type="hidden" name="chroot" value="no">
<input id="a3" type="checkbox" name="chroot" value="yes"$chroot_chk><label for="a3"> $(lang de:"chroot jail" en:"chroot jail")</label>
</p>
<p>
<input type="hidden" name="allow_root" value="no">
<input id="a1" type="checkbox" name="allow_root" value="yes"$root_chk><label for="a1"> $(lang de:"Erlaube root login" en:"Allow root login")</label>
</p>
EOF

sec_end
