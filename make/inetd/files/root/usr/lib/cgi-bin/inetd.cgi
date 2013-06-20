#!/bin/sh


. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cgi_print_radiogroup_service_starttype \
	"enabled" "$INETD_ENABLED" "" "" 0

sec_end

sec_begin '$(lang de:"Internet 'Superserver' (inetd)" en:"Internet 'super-server' (inetd)")'

if [ -d /proc/sys/net/ipv6 ] || find /lib/modules/*-*/kernel/net/ipv6 -maxdepth 1 -name ipv6.ko >/dev/null 2>&1; then
	cgi_print_checkbox_p "ipv6_support" "$INETD_IPV6_SUPPORT" \
		"$(lang de:"Aktiviere IPv6 Unterst&uuml;tzung" en:"Enable IPv6 support")."
fi

cat << EOF
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
EOF
cgi_print_textline_p "options" "$INETD_OPTIONS" 20/255 "$(lang de:"Optionen" en:"Options"): "

sec_end
