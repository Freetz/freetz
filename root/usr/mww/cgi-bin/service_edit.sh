source /usr/lib/mod/service.sh

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

cgi --style=mod/daemons.css
cgi_begin '$(lang de:"Dienste" en:"Services")' 'daemons'

view=$(cgi_param view | tr -d .)

case $view in
	"")
		stat_avm
		stat_builtin
		stat_static
		;;
	builtin)
		stat_builtin
		;;
	static)
		stat_static
		;;
	*)
		print_error "$(lang de:"Unbekannte Ansicht" en:"unknown view") '$view'"
		;;
esac

cgi_end
