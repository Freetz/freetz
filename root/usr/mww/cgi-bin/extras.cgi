#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

[ -e "/mod/etc/reg/extra.reg" ] || touch /mod/etc/reg/extra.reg

if [ -z "$PATH_INFO" ]; then
	_cgi_extras() {
		if [ -s "/mod/etc/reg/extra.reg" ]; then
			[ -e "/mod/etc/reg/cgi.reg" ] || touch /mod/etc/reg/cgi.reg

			cat /mod/etc/reg/extra.reg | while IFS='|' read -r pkg title sec cgi; do
				if [ ! -z "$title" ]; then
					if [ "$cur_pkg" != "$pkg" ]; then
						[ -z "$cur_pkg" ] || echo '</ul>'

						if [ "$pkg" = "mod" ]; then
							echo '<h1>$(lang de:"Mod Extras" en:"Mod extras")</h1>'
						else
							IFS='|'; set -- $(cat /mod/etc/reg/cgi.reg | grep "^$pkg")
							if [ -z "$2" ]; then echo "<h1>$pkg</h1>"; else echo "<h1>$2</h1>"; fi
						fi

						echo '<ul>'
						cur_pkg="$pkg"
					fi
					echo "<li><a href=\"/cgi-bin/extras.cgi/$pkg/$cgi\">$title</a></li>"
				fi
			done
			echo '</ul>'
		else
			echo '<p><i>$(lang de:"keine Extras" en:"no extras")</i></p>'
		fi
	}

	cgi_begin 'Extras' 'extras'

	[ -e "/mod/var/cache/extras" ] || _cgi_extras > /mod/var/cache/extras
	cat /mod/var/cache/extras

	cgi_end
else
	sec_level=1
	[ -r "/tmp/flash/security" ] && let sec_level="$(cat /tmp/flash/security)"

	OIFS="$IFS"
	IFS='/'
	set -- $(echo "$PATH_INFO" | sed -e 's/\.//g')
	pkg="$2"; cgi="$3"
	IFS='|'
	set -- $(cat /mod/etc/reg/extra.reg | grep "^$pkg|.*|$cgi\$")
	IFS="$OIFS"

	sec=1
	[ -z "$3" ] || let sec="$3"

	if [ "$sec_level" -gt "$sec" ]; then
		cgi_begin 'Extras'
		echo '<h1>$(lang de:"Zusatz-Skript" en:"Additional script")</h1>'
		echo '<div style="color: #800000;">$(lang de:"Dieses Zusatz-Skript in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" en:"This script is not available at the current security level!")</div>'
		echo '</p><form action="/cgi-bin/extras.cgi"><input type="submit" value="$(lang de:"Zu den Extras" en:"Goto extras")"></form></p>'
		cgi_end
	else
		if [ -x "/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi" ]; then
			/mod/usr/lib/cgi-bin/$pkg/$cgi.cgi
		else
			cgi_begin 'Extras'
			echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Zusatz-Skript '$cgi.cgi' nicht gefunden." en:"Additional script '$cgi.cgi' not found.")</p>"
			cgi_end
		fi
	fi
fi
