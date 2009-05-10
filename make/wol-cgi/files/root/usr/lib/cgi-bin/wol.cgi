#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk= man_chk= inetd_chk=

case $WOL_ENABLED in
	yes)	auto_chk=' checked' ;;
	inetd)	inetd_chk=' checked' ;;
	*)	man_chk=' checked' ;;
esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
[ -e /mod/etc/default.inetd/inetd.cfg ] &&
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"Bekannte Hosts" en:"Known hosts")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=Freetz__hosts">$(lang de:"Hosts bearbeiten" en:"Edit hosts")</a></li>
</ul>
<p style="font-size:10px;">($(lang de:"alle Eintr&auml;ge, die eine g&uuml;ltige MAC Adresse aufweisen" en:"all items with a valid MAC address"))</p>
EOF

sec_end
sec_begin '$(lang de:"WOL Interface" en:"WOL interface")'

cat << EOF
<h2>$(lang de:"Port des WOL Webservers" en:"Port of WOL webserver"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$WOL_PORT")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zugriff" en:"Access")'

cat << EOF
<p>$(lang de:"Benutzer" en:"User"): <input type="text" name="user" size="20" maxlength="255" value="$(html "$WOL_USER")"></p>
<p>$(lang de:"Passwort" en:"Password"): <input type="password" name="plain_passwd" size="20" maxlength="255" value="$(html "$WOL_PLAIN_PASSWD")"></p>
EOF

sec_end
