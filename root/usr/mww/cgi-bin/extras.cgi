#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

extra_reg=/mod/etc/reg/extra.reg
cgi_reg=/mod/etc/reg/cgi.reg
cache=/mod/var/cache/extras

[ -e "$extra_reg" ] || touch "$extra_reg"

if [ -z "$PATH_INFO" ]; then
	_cgi_extras() {
		if [ ! -s "$extra_reg" ]; then
			echo '<p><i>$(lang de:"keine Extras" en:"no extras")</i></p>'
			return
		fi
		[ -e "$cgi_reg" ] || touch "$cgi_reg"

		unset cur_pkg
		cat "$extra_reg" | while IFS='|' read -r pkg title sec cgi; do
			[ -z "$title" ] && continue
			if [ "$cur_pkg" != "$pkg" ]; then
				[ -z "$cur_pkg" ] || echo '</ul>'

				if [ "$pkg" = "mod" ]; then
					echo '<h1>$(lang de:"Mod Extras" en:"Mod extras")</h1>'
				else
					IFS='|'; set -- $(grep "^$pkg" "$cgi_reg")
					echo "<h1>${2:-$pkg}</h1>"
				fi

				echo '<ul>'
				cur_pkg="$pkg"
			fi
			echo "<li><a href='$(href extra "$pkg" "$cgi")'>$title</a></li>"
		done
		echo '</ul>'
	}

	cgi_begin 'Extras' 'extras'

	[ -e "$cache" ] || _cgi_extras > "$cache"
	cat "$cache"

	cgi_end
else
	OIFS=$IFS
	IFS='/'
	set -- $(echo "$PATH_INFO" | tr -d .)
	pkg=$2; cgi=$3
	IFS='|'
	set -- $(grep "^$pkg|.*|$cgi\$" "$extra_reg")
	IFS=$OIFS

	if [ "$sec_level" -gt "$3" ]; then
		cgi_begin 'Extras'
		echo '<h1>$(lang de:"Zusatz-Skript" en:"Additional script")</h1>'
		echo '<div style="color: #800000;">$(lang de:"Dieses Zusatz-Skript in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" en:"This script is not available at the current security level!")</div>'
		echo '<p>'
		back_button /cgi-bin/extras.cgi "$(lang de:"Zu den Extras" en:"Goto extras")"
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
