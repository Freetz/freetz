#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

eval "$(modcgi oldpassword:password:replay mod_cgi)"

(echo "$MOD_CGI_OLDPASSWORD"; echo "$MOD_CGI_PASSWORD"; echo "$MOD_CGI_REPLAY") |
	modpasswd freetz > /dev/null 2>&1
result=$?

cgi_begin 'Passwort' 'password'

if [ "$result" -ne 0 ]; then
	echo '<h1>$(lang de:"Passwort wurde nicht ge&auml;ndert." en:"Password unchanged.")</h1>'
	if [ "$result" -eq 2 ]; then
	    echo '<p>$(lang de:"Falsches (altes) Passwort." en:"Wrong (old) password.")</p>'
	fi
else
	echo '<h1>$(lang de:"Passwort erfolgreich ge&auml;ndert." en:"New password set.")</h1>'
	echo '<p>$(lang de:"Starte Weboberfläche neu..." en:"Restarting webcfg...")</p>'
	/etc/init.d/rc.webcfg restart > /dev/null 2>&1
fi

cat << EOF
<form action="/cgi-bin/status.cgi" method=POST>
<input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")">
</form>
EOF
	
cgi_end
