#!/bin/sh

. /usr/lib/libmodcgi.sh
. /mod/etc/conf/openvpn.cfg

NAMES="${OPENVPN_CONFIG_NAMES#*\#}"
NAMES="openvpn${NAMES//#/\nopenvpn_}"
MODE="${OPENVPN_MODE#*\#}"
LOG="${OPENVPN_LOGFILE#*\#}"
nth() {
	echo -e "${2//#/\n}" | sed -n "$1 p"
}

cgi_begin "OpenVPN Clients"

sec_begin "$(lang de:"Verbundene VPN-Clients" en:"Connected clients")" sec-connected

echo "<p>$(lang de:"Laut Status-Datei sind folgende Clients verbunden:" en:"Status file entries of connected sessions:") </p>"

c=1
for config in $(echo -e "$NAMES"); do
	if [ "yes" = "$(nth $c $LOG)" -a "server" = "$(nth $c $MODE)" -a -r /var/log/${config}.log ]; then
		[ $OPENVPN_CONFIG_COUNT -gt 1 ] && echo "<b>$(lang de:"Konfiguration" en:"Configuration") <i>${config}</i></b> "
		echo '<table width="100%" border="1" rules="rows">'
		echo "<tr><th align="left">Clientname</th><th align="left">IP</th><th align="left">$(lang de:"verbunden seit" en:"connected since")</th></tr>"
		sed -n '/Since/,/ROUTING/ s%\(^[^\,]*\)\,\([0-9\.]*\)[^\,]*\,[0-9]*\,[0-9]*\,\(.*\)%<tr> <td>\1</td><td>\2</td><td>\3</td></tr>% p' /var/log/${config}.log
		echo "</table>"
		echo "<small>($(lang de:"Status von" en:"Status at"):  $(sed -n 's/^Updated\,//p' /var/log/${config}.log )) </small><p></p>"
	fi
	let c++
done
echo "<p><small><i>$(lang de:"Angezeigt nur f&uuml;r konfigurierte Server mit angew&auml;hlter Option \"Statusprotokoll\"" en:"Shown only for server configurations with selected option \"Log status\"") </i></small></p>"

sec_end

cgi_end

