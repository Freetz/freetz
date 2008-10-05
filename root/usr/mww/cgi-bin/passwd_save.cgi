#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

eval "$(modcgi password mod_cgi)"

(echo $MOD_CGI_PASSWORD;sleep 1;echo $MOD_CGI_PASSWORD) | modpasswd freetz > /dev/null
result=$?

cgi_begin 'Passwort' 'password'

if [ "$result" -ne 0 ]; then
	echo '<h1>$(lang de:"Passwort wurde nicht ge&auml;ndert." en:"Password unchanged.")</h1>'
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
