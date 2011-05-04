#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$INETD_ENABLED" yes:auto "*":man
check "$INETD_IPV6_SUPPORT" yes:ipv6_support

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Internet 'Superserver' (inetd)" en:"Internet 'super-server' (inetd)")'

if [ -d /proc/sys/net/ipv6 ] || find /lib/modules/*-*/kernel/net/ipv6 -maxdepth 1 -name ipv6.ko >/dev/null 2>&1; then
cat << EOF
<p>
<input type="hidden" name="ipv6_support" value="no">
<input id="i1" type="checkbox" name="ipv6_support" value="yes"$ipv6_support_chk><label for="i1"> $(lang de:"Aktiviere IPv6 Unterst&uuml;tzung" en:"Enable IPv6 support").</label>
</p>
EOF
fi

cat << EOF
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
<p>$(lang de:"Optionen" en:"Options"): <input type="text" name="options" size="20" maxlength="255" value="$(html "$INETD_OPTIONS")"></p>
EOF

sec_end
