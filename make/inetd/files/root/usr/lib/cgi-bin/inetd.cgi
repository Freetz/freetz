#!/bin/sh


. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Internet 'Superserver' (inetd)" en:"Internet 'super-server' (inetd)")"

if [ -d /proc/sys/net/ipv6 ] || find /lib/modules/*-*/kernel/net/ipv6 -maxdepth 1 -name ipv6.ko >/dev/null 2>&1; then
	cgi_print_checkbox_p "ipv6_support" "$INETD_IPV6_SUPPORT" \
		"$(lang de:"Aktiviere IPv6 Unterst&uuml;tzung" en:"Enable IPv6 support")."
fi

cgi_print_textline_p "slq" "$INETD_SLQ" 4/5 "$(lang de:"Gr&ouml;&szlig;e Socket-Abh&ouml;rwarteschlange" en:"Size of socket listen queue"): "
cgi_print_textline_p "psa" "$INETD_PSA" 4/5 "$(lang de:"Maximum Verbindungen pro Minute" en:"Maximum connections per minute"): "

sec_end
