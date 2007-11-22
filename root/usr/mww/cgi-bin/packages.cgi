#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin '$(lang de:"Pakete" en:"Packages")' 'packages'

cat << EOF
<h1>$(lang de:"Paket-Einstellungen" en:"Package settings")</h1>
<p>$(lang de:"Bitte einen Unterpunkt w&auml;hlen." en:"Please choose a package.")</p>
EOF

echo '<ul>'

if [ -r "/mod/etc/reg/cgi.reg" ]; then
	cat /mod/etc/reg/cgi.reg | while IFS='|' read -r pkg title; do
		echo "<li><a href=\"/cgi-bin/pkgconf.cgi?pkg=$pkg\">$title</a></li>"
	done
fi

echo '</ul>'

cgi_end
