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

if [ -r "/mod/etc/default.$PACKAGE/$PACKAGE.cfg" ]; then
	. /mod/etc/conf/$PACKAGE.cfg
fi

cgi_begin "$PACKAGE_TITLE" "$MENU_ID"

if [ -x "/mod/usr/lib/cgi-bin/$PACKAGE.cgi" ]; then
	frm_begin "$PACKAGE"
	/mod/usr/lib/cgi-bin/$PACKAGE.cgi
	frm_end "$PACKAGE"
else
	print_error "$(lang de:"Kein Skript f&uuml;r das Paket" en:"no script for package") '$PACKAGE'."
fi

cgi_end
