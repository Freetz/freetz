#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /usr/lib/libmodfrm.sh

package=$(cgi_param pkg | tr -d .)
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
		echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Kein Skript f&uuml;r das Paket" en:"no script for package") '$package'.</p>"
	fi

	cgi_end
else
	cgi_begin "$(lang de:"Fehler" en:"Error")" "pkg:$package"
	echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Das Paket '$package' ist nicht konfigurierbar." en:"the package '$package' is not configurable.")</p>"
	cgi_end
fi
