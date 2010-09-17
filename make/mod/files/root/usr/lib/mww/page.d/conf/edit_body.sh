frm_begin() {
	cat << EOF
<form method="post">
EOF
}

frm_end() {
	cat << EOF
<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>
</form>
<form class="btn" action="?default" method="post">
<div class="btn"><input type="submit" value="$(lang de:"Standard" en:"Defaults")"></div>
</form>
EOF
}

source /usr/lib/mod/service.sh
SERVICE_REG=/mod/etc/reg/daemon.reg
package_services() {
	local selected_pkg=$1 count=0
	while IFS='|' read -r daemon description rcscript disable hide pkg; do
		[ "$pkg" = "$selected_pkg" -a "$hide" = false ] || continue
		let count++
		if [ $count -eq 1 ]; then
			sec_begin '$(lang de:"Status" en:"Status")'
			stat_begin
		fi
		stat_line "$pkg" "$daemon" "$description" "$rcscript" "$disable" "$hide"
	done < "$SERVICE_REG"
	if [ $count -gt 0 ]; then
		stat_end
		sec_end
	fi
}

if [ -r "/mod/etc/default.$PACKAGE/$PACKAGE.cfg" ]; then
	. /mod/etc/conf/$PACKAGE.cfg
fi

if [ "$ID" = _index ]; then
	cgi="/mod/usr/lib/cgi-bin/$PACKAGE.cgi"
else
	cgi="/mod/usr/lib/cgi-bin/$PACKAGE/$ID.cgi"
fi

package_services "$PACKAGE"

if [ -x "$cgi" ]; then
	frm_begin "$PACKAGE"
	"$cgi"
	frm_end "$PACKAGE"
else
	print_error "$(lang de:"Kein Skript f&uuml;r" en:"No script for") '$PACKAGE/$ID'."
fi
