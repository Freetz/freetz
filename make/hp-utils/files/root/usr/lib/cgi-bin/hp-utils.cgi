#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk= man_chk= inetd_chk=

case $HP_UTILS_ENABLED in
	yes)	auto_chk=' checked' ;;
	inetd)	inetd_chk=' checked' ;;
	*)	man_chk=' checked' ;;
esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
[ -e /mod/etc/default.inetd/inetd.cfg ] &&
cat << EOF
<input id="e3" type="radio" name="enabled" value="inetd"$inetd_chk><label for="e3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
cat << EOF
</p>
EOF

sec_end
sec_begin '$(lang de:"Drucker" en:"Printer")'

cat << EOF
<p>URI: <input type="text" name="uri" size="60" maxlength="255" value="$(html "$HP_UTILS_URI")"></p>
EOF

sec_end
sec_begin '$(lang de:"hp-utils-Interface" en:"hp-utils interface")'

cat << EOF
<h2>$(lang de:"Port des hp-utils-Webservers" en:"Port of hp-utils webserver"):</h2>
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$HP_UTILS_PORT")"></p>
EOF

sec_end
sec_begin '$(lang de:"Zugriff" en:"Access")'

cat << EOF
<p>$(lang de:"Benutzer" en:"User"): <input type="text" name="user" size="20" maxlength="255" value="$(html "$HP_UTILS_USER")"></p>
<p>$(lang de:"Passwort" en:"Password"): <input type="password" name="plain_passwd" size="20" maxlength="255" value="$(html "$HP_UTILS_PLAIN_PASSWD")"></p>
EOF

sec_end
