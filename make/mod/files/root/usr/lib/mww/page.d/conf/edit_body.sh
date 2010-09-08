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
	local selected_pkg=$1
	grep -q "|$selected_pkg\$" "$SERVICE_REG" 2> /dev/null || return
	sec_begin '$(lang de:"Dienste" en:"Services")'
	stat_begin
	while IFS='|' read -r daemon description rcscript disable hide pkg; do
		[ "$pkg" = "$selected_pkg" ] || continue
		stat_line "$pkg" "$daemon" "$description" "$rcscript" "$disable" "$hide"
	done < "$SERVICE_REG"
	stat_end
	sec_end
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
