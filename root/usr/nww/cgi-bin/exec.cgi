#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

eval "$(modcgi cmd mod_cgi)"

case "$MOD_CGI_CMD" in
	telnetd)
		cgi_begin '$(lang de:"Starte" en:"Starting") telnetd...'
		echo '<p>$(lang de:"Starte" en:"Starting") telnetd:</p>'
		echo -n '<pre>'
		/etc/init.d/rc.telnetd start
		echo '</pre>'
		echo '<form action="/cgi-bin/index.cgi"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>'
		cgi_end
		;;
	reboot)
		cgi_begin 'Reboot...'
		echo '<p>$(lang de:"Starte neu" en:"Rebooting")...</p>'
		echo '<p>$(lang de:"Nach dem Neustart <a href=\"/\" target=\"topframe\">hier</a> mit dem Benutzer '\"'\"'admin'\"'\"' und dem neuen Passwort einloggen." en:"You can login <a href=\"/\" target=\"topframe\">here</a> as user '\"'\"'admin'\"'\"' with the newly created password after reboot.")</p>'
		cgi_end
		reboot
		;;
	*)
		cgi_begin '$(lang de:"Fehler" en:"Error")'
		echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannter Befehl" en:"unknown command") '$MOD_CGI_CMD'</p>"
		cgi_end
		;;
esac
