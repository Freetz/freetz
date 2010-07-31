#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

frm_begin() {
cat << EOF
<form action="/cgi-bin/save.cgi/$1" method="post">
EOF
}

frm_end() {
cat << EOF
<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>
</form>
<form class="btn" action="/cgi-bin/save.cgi/$1?default" method="post">
<div class="btn"><input type="submit" value="$(lang de:"Standard" en:"Defaults")"></div>
</form>
EOF
}

path_info package _
if ! valid package "$package"; then
    	cgi_error "Invalid path"
fi

cgi_reg=/mod/etc/reg/cgi.reg
[ -e "$cgi_reg" ] || touch "$cgi_reg"

if [ -r "/mod/etc/default.$package/$package.cfg" -o -r "/mod/etc/default.$package/$package.save" ]; then
	if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
		. /mod/etc/conf/$package.cfg
	fi

	if [ "$package" = mod ]; then
		cgi_begin '$(lang de:"Einstellungen" en:"Settings")' 'settings'
	else
		OIFS=$IFS; IFS="|"
		set -- $(grep "^$package|" "$cgi_reg")
		IFS=$OIFS
		cgi_begin "${2:-$package}" "pkg:$package"
	fi

	if [ -x "/mod/usr/lib/cgi-bin/$package.cgi" ]; then
		frm_begin "$package"
		/mod/usr/lib/cgi-bin/$package.cgi
		frm_end "$package"
	else
		print_error "$(lang de:"Kein Skript f&uuml;r das Paket" en:"no script for package") '$package'."
	fi

	cgi_end
else
	cgi_error "$(lang de:"Das Paket '$package' ist nicht konfigurierbar." en:"the package '$package' is not configurable.")" "pkg:$package"
fi
