#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /usr/lib/libmodfrm.sh

package="$(echo "$QUERY_STRING" | sed -e 's/^.*pkg=//' -e 's/&.*$//' -e 's/\.//g')"

if [ -r "/mod/etc/default.$package/$package.cfg" -o -r "/mod/etc/default.$package/$package.save" ]; then
	if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
		. /mod/etc/conf/$package.cfg
	fi

	cgi_begin "$package" "pkg_$package"
	

	if [ -x "/mod/usr/lib/cgi-bin/$package.cgi" ]; then
		frm_begin "$package"
		/mod/usr/lib/cgi-bin/$package.cgi
		frm_end "$package"
	else
		echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Kein Skript f&uuml;r das Paket" en:"no script for package") '$package'.</p>"
	fi

	cgi_end
else
	cgi_begin "$(lang de:"Fehler" en:"Error")" "pkg_$package"
	echo "<p><b>$(lang de:"Fehler" en:"Error"):</b> $(lang de:"Das Paket '$package' ist nicht konfigurierbar." en:"the package '$package' is not configurable.")</p>"
	cgi_end
fi
