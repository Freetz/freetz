#!/bin/sh

PACKAGEURL=/cgi-bin/pkgconf.cgi?pkg=
SETTINGSURL=/cgi-bin/settings.cgi
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

stat_begin() {
	echo '<table border="0" cellspacing="1" cellpadding="0">'
}

stat_button() {
	if [ "$3" -eq 0 ]; then disabled=" disabled"; else disabled=""; fi
	echo '<td><form class="btn" action="/cgi-bin/exec.cgi" method="post"><input type="hidden" name="pkg" value="'"$1"'"><input type="hidden" name="cmd" value="'"$2"'"><input type="submit" value="'"$2"'"'"$disabled"'></form></td>'
}

stat_packagelink() {
	if [ "$1" = "crond" -o "$1" = "swap" -o "$1" = "telnetd" -o "$1" = "webcfg" ]; then
		echo '<a href="'"$SETTINGSURL"'">'"$1"'</a>'
	else
 		echo '<a href="'"$PACKAGEURL$1"'">'"$1"'</a>'
	fi
}
stat_line() {
	status="$(/mod/etc/init.d/rc.$1 status 2> /dev/null)"
	if [ -n "$2" ]; then name="$2"; else name="$1"; fi
	case "$status" in
		running)
			color="#008000"
			start=0; stop=1
			;;
		stopped)
			color="#800000"
			start=1; stop=0
			;;
		inetd)
			case "$inetd_status" in
				running)
					color="#008000"
					;;
				stopped)
					color="#800000"
					;;
				none)
					color="#808080"
					inetd_status='<i>none</i>'
					;;
				*)	color="#000000"
					;;
			esac
			status="$inetd_status ($status)"
			start=0; stop=0;
			;;
		none)
			status='<i>none</i>'
			color="#808080"
			start=1; stop=0
			;;
		*)
			color="#000000"
			start=1; stop=1
			;;
	esac
	echo '<tr>'
	echo '<td width="180">'$(stat_packagelink $name)'</td><td style="color: '"$color"';" width="120">'"$status"'</td>'

	stat_button $1 start $start
	stat_button $1 stop $stop
	stat_button $1 restart $stop

	echo '</tr>'
}

stat_end() {
	echo '</table>'
}

stat_builtin() {
	sec_begin '$(lang de:"Basis-Pakete" en:"Built-in packages")'
	stat_begin

	stat_line 'crond'
	stat_line 'swap'
	stat_line 'telnetd'
	stat_line 'webcfg'

	stat_end
	sec_end
}

stat_static() {
	sec_begin '$(lang de:"Statische Pakete" en:"Static packages")'
	stat_begin

	empty=1
	if [ -e /etc/static.pkg ]; then
		for pkg in $(cat /etc/static.pkg); do
			if [ -x "/mod/etc/init.d/rc.$pkg" ] && [ ! -e "/mod/etc/${pkg}_multid.pkg" ]; then
				empty=0
				stat_line "$pkg"
			else
				if [ -e "/mod/etc/${pkg}_multid.pkg" ]; then
					empty=0
					echo "<tr><td><b>Deamons <i>${pkg}</i>:</b></td></tr>"
					for pkgline in $(cat /mod/etc/${pkg}_multid.pkg); do
						if [ -n "$(echo $pkgline | grep \#)" ]; then
							mpkg=${pkgline%%#*};
							name=${pkgline#*#};
						else
							mpkg=$pkgline
							name=$pkgline
						fi
						stat_line "$mpkg" "&nbsp;&nbsp;&nbsp;&nbsp;$name"
					done
				fi
			fi
		done
	fi
	if [ "$empty" -eq 1 ]; then
		echo '<p><i>$(lang de:"keine statischen Pakete" en:"no static packages")</i></p>'
	fi

	stat_end
	sec_end
}

stat_dynamic() {
	sec_begin '$(lang de:"Dynamische Pakete" en:"Dynamic packages")'

	echo '<p><i>$(lang de:"(noch) nicht implementiert" en:"not implemented yet")</i></p>'

	sec_end
}

cgi_begin '$(lang de:"Dienste" en:"Services")' 'daemons'

view="$(echo "$QUERY_STRING" | sed -e 's/^.*view=//' -e 's/&.*$//' -e 's/\.//g')"

if [ -e /etc/default.inetd/inetd.cfg ]; then
	inetd=true
else
	inetd=false
fi
if [ "true" == "$inetd" ]; then
	inetd_status="$(/etc/init.d/rc.inetd status 2> /dev/null)"
fi

# comment out dynamic packages until we implemented it

case "$view" in
	"")
		stat_builtin
		stat_static
#		stat_dynamic
		;;
	builtin)
		stat_builtin
		;;
	static)
		stat_static
		;;
#	dynamic)
#		stat_dynamic
#		;;
	*)
		echo "<p><b>$(lang de:"Fehler" en:"Error")</b>: $(lang de:"Unbekannte Ansicht" en:"unknown view") '$view'</p>"
		;;
esac

cgi_end
