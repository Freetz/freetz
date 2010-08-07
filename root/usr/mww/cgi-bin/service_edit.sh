stat_begin() {
	echo '<table class="daemons" border="0" cellspacing="1" cellpadding="0">'
}

stat_button() {
	local pkg=$1 daemon=$2 cmd=$3 active=$4
	if ! $active; then disabled=" disabled"; else disabled=""; fi
	echo "<td><form class='btn' action='/cgi-bin/service.cgi/$pkg/$daemon' method='post'><input type='submit' name='cmd' value='$cmd'$disabled></form></td>"
}

stat_packagelink() {
	local url
	case $1 in
		mod) url=$(href mod conf) ;;
		*)   url=$(href cgi "$1") ;;
	esac
	echo "<a href='$url'>$2</a>"
}

stat_line() {
	local pkg=$1
	local daemon=$2
	local description=${3:-$daemon}
	local rcfile="/mod/etc/init.d/${4:-rc.$daemon}"
	local disable=${5:-false}
	local hide=${6:-false}

	$hide && return

	local start=false stop=false
	local status=$("$rcfile" status 2> /dev/null)
	case $status in
		running | 'running (inetd)')
			class=running
			stop=true
			;;
		stopped | 'stopped (inetd)')
			class=stopped
			start=true
			;;
		inetd)
			case $inetd_status in
				running)
					class=running
					;;
				stopped)
					class=stopped
					;;
				none)
					class=none
					inetd_status='<i>none</i>'
					;;
				*)	class=
					;;
			esac
			status="$inetd_status ($status)"
			;;
		none)
			status='<i>none</i>'
			class=none
			start=true
			;;
		*)
			class=
			start=true; stop=true
			;;
	esac
	echo "<tr${class:+ class='$class'}>"
	echo "<td width='180'>$(stat_packagelink "$pkg" "$description")</td><td class='status' width='120'>$status</td>"

	if $disable; then
		start=false; stop=false
	fi
	stat_button "$pkg" "$daemon" start $start
	stat_button "$pkg" "$daemon" stop $stop
	stat_button "$pkg" "$daemon" restart $stop

	echo '</tr>'
}

stat_end() {
	echo '</table>'
}

stat_avm() {
	sec_begin '$(lang de:"AVM-Dienste" en:"AVM services")'
	stat_begin

	stat_line mod dsld
	stat_line mod multid
	stat_line mod telnetd
	[ -x /etc/init.d/rc.ftpd ] && [ "$(echo usbhost.ftp_server_enabled | usbcfgctl -s)" != "no" ] && stat_line mod ftpd

	stat_end
	sec_end
}

stat_builtin() {
	sec_begin '$(lang de:"Basis-Pakete" en:"Built-in packages")'
	stat_begin

	stat_line mod crond
	stat_line mod swap
	stat_line mod webcfg

	stat_end
	sec_end
}

stat_static() {
	sec_begin '$(lang de:"Statische Pakete" en:"Static packages")'
	stat_begin

	if [ -r "$REG" ]; then
	    	# order by description
		while IFS='|' read -r daemon description rest; do
			echo "$description|$daemon|$rest"
		done < "$REG" | sort |
		while IFS='|' read -r description daemon rcscript disable hide pkg; do
			stat_line "$pkg" "$daemon" "$description" "$rcscript" "$disable" "$hide"
		done
	fi
	if [ ! -s "$REG" ]; then
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

cgi --style=mod/daemons.css
cgi_begin '$(lang de:"Dienste" en:"Services")' 'daemons'

view=$(cgi_param view | tr -d .)

if [ -e /etc/default.inetd/inetd.cfg ]; then
	inetd_status=$(/etc/init.d/rc.inetd status 2> /dev/null)
fi

# comment out dynamic packages until we implemented it

case $view in
	"")
		stat_avm
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
		print_error "$(lang de:"Unbekannte Ansicht" en:"unknown view") '$view'"
		;;
esac

cgi_end
