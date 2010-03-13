#!/bin/sh

PACKAGEURL=/cgi-bin/pkgconf.cgi?pkg=
SETTINGSURL=/cgi-bin/settings.cgi
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

stat_begin() {
	echo '<table border="0" cellspacing="1" cellpadding="0">'
}

stat_button() {
	if ! $3 ; then disabled=" disabled"; else disabled=""; fi
	echo '<td><form class="btn" action="/cgi-bin/exec.cgi" method="post"><input type="hidden" name="pkg" value="'"$1"'"><input type="hidden" name="cmd" value="'"$2"'"><input type="submit" value="'"$2"'"'"$disabled"'></form></td>'
}

stat_packagelink() {
	local url
	case $1 in
		crond|swap|telnetd|webcfg) url="$SETTINGSURL" ;;
		*) url="$PACKAGEURL$1" ;;
	esac
	echo "<a href='$url'>$2</a>"
}

stat_line() {
	pkg=$1
	name=${2:-$pkg}
	rcfile=/mod/etc/init.d/${3:-rc.$pkg}
	disable=${4:-false}
	hide=${5:-false}
	config_pkg=${6:-$pkg}
	if $hide; then return; fi

	status=$("$rcfile" status 2> /dev/null)
	case $status in
		running)
			color="#008000"
			start=false; stop=true
			;;
		stopped)
			color="#800000"
			start=true; stop=false
			;;
		inetd)
			case $inetd_status in
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
			start=false; stop=false
			;;
		none)
			status='<i>none</i>'
			color="#808080"
			start=true; stop=false
			;;
		*)
			color="#000000"
			start=true; stop=true
			;;
	esac
	echo '<tr>'
	echo '<td width="180">'$(stat_packagelink $config_pkg $name)'</td><td style="color: '"$color"';" width="120">'"$status"'</td>'

	if $disable ; then
		start=false; stop=false;
	fi
	stat_button $pkg start $start
	stat_button $pkg stop $stop
	stat_button $pkg restart $stop

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

        if [ -r /mod/etc/reg/daemon.reg ]; then
		while IFS='|' read -r pkg name rcscript disable hide parentpkg; do
			stat_line "$pkg" "$name" "$rcscript" $disable $hide "$parentpkg"
		done < /mod/etc/reg/daemon.reg
	fi
	if [ ! -s /mod/etc/reg/daemon.reg ]; then
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

view=$(cgi_param view | tr -d .)

if [ -e /etc/default.inetd/inetd.cfg ]; then
	inetd=true
else
	inetd=false
fi
if $inetd; then
	inetd_status=$(/etc/init.d/rc.inetd status 2> /dev/null)
fi

# comment out dynamic packages until we implemented it

case $view in
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
