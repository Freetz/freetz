SERVICE_REG=/mod/etc/reg/daemon.reg
SERVICE_PKG=/mod/etc/reg/pkg.reg
source /usr/lib/mod/service.sh

stat_avm() {
	sec_begin "$(lang de:"AVM-Dienste" en:"AVM services")"
	stat_begin

	select_avm() [ "$1" = avm ]
	stat_lines select_avm

	stat_end
	sec_end
}

stat_builtin() {
	sec_begin "$(lang de:"Basis-Pakete" en:"Built-in packages")"
	stat_begin

	select_mod() [ "$1" = mod ]
	stat_lines select_mod

	stat_end
	sec_end
}

stat_lines() {
	local predicate=$1 # function name (signature: pkg=$1 id=$2)
	if [ -r "$SERVICE_REG" ]; then
		# order by description
		while IFS='|' read -r daemon description rest; do
			sed -n "s/^$daemon|//p" "$SERVICE_PKG" | tr -d '\n'
			echo "|$description|$daemon|$rest"
		done < "$SERVICE_REG" | sort |
		while IFS='|' read -r long description daemon rcscript disable hide pkg; do
			"$predicate" "$pkg" "$daemon" || continue
			stat_line "$pkg" "$daemon" "${long:-$description}" "$rcscript" "$disable" "$hide"
		done
	fi
}

stat_static() {
	sec_begin "$(lang de:"Statische Pakete" en:"Static packages")"
	stat_begin

	select_static() [ "$1" != avm -a "$1" != mod ]
	stat_lines select_static
	if [ ! -s "$SERVICE_REG" ]; then
		echo "<p><i>$(lang de:"keine statischen Pakete" en:"no static packages")</i></p>"
	fi

	stat_end
	sec_end
}

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

