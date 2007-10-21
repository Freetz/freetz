#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

eval "$(modcgi password mod_cgi)"

(echo $MOD_CGI_PASSWORD;sleep1;echo $MOD_CGI_PASSWORD) | modpasswd dsmod > /dev/null
result=$?

cgi_begin 'Passwort' 'password'

if [ "$result" -neq 0 ]; then
    echo '<h1>$(lang de:"Passwort konnte nicht ge&auml;ndert." en:"Password unchanged.")</h1>'
else
    echo '<h1>$(lang de:"Passwort erfolgreich ge&auml;ndert." en:"New password set.")</h1>'
    echo '<p>$(lang de:"Bitte Weboberfl&auml;che neustarten." en:"Please restart webcfg.")</p>'
fi

cat << EOF
<form action="/cgi-bin/status.cgi" method=POST>
<input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")">
</form>
EOF
	
cgi_end