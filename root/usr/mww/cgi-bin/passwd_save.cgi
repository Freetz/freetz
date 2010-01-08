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

	#XMail admin account
	if [ -x /usr/lib/MailRoot/bin/XMCrypt ]; then
		local DAEMON="xmail"
		. /etc/init.d/modlibrc
		if [ -e $XMAIL_MAILLOCATION/ctrlaccounts.tab ]; then
			xmcryptpass=$(/usr/lib/MailRoot/bin/XMCrypt $MOD_CGI_PASSWORD)
			if [ -z "$xmcryptpass" ]; then
				echo 'ERROR: No encrypted Password received from XMCrypt,'
				echo '       Password for XMail control not changed !!!'
			else
				(
					sed -e "/\"$MOD_HTTPD_USER\"/d" $XMAIL_MAILLOCATION/ctrlaccounts.tab
					echo -e "\"$MOD_HTTPD_USER\"\t\"$xmcryptpass\""
				) > $XMAIL_MAILLOCATION/ctrlaccounts.tab
			
				#/etc/init.d/rc.xmail restart

				#PHPXmail server.php
				[ -d /usr/mww/phpxmail ] && (
					[ -e /tmp/flash/phpxmail/servers.php ] && sed -e \
					"/^.*\t\(127\.0\.0\.1\|localhost\)\t.*\t$MOD_HTTPD_USER\t/d" /tmp/flash/phpxmail/servers.php
					echo -e "$(lang de:"Lokale" en:"Local") Fritz!Box\t127.0.0.1\t6017\t$MOD_HTTPD_USER\t$xmcryptpass\t0"
				) >/tmp/flash/phpxmail/servers.php && modsave flash > /dev/null
			fi
		fi
	fi
fi

cat << EOF
<form action="/cgi-bin/status.cgi" method=POST>
<input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")">
</form>
EOF
	
cgi_end
