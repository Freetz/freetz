#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
log_chk=''
webcfg_chk=''
ifilt_chk=''
icmp_chk=''
hosts_chk=''

if [ "$FIREWALL_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$FIREWALL_LOG" = "yes" ]; then log_chk=' checked'; fi
if [ "$FIREWALL_WEBCFG" = "yes" ]; then webcfg_chk=' checked'; fi
if [ "$FIREWALL_IFILT" = "yes" ]; then ifilt_chk=' checked'; fi
if [ "$FIREWALL_ICMP" = "yes" ]; then icmp_chk=' checked'; fi
if [ "$FIREWALL_HOSTS" = "yes" ]; then hosts_chk=' checked'; fi

webcfg_eth0_sel=''
webcfg_eth1_sel=''
webcfg_usb_sel=''
webcfg_wlan_sel=''

case "$FIREWALL_WEBCFG_IF" in
	eth0) webcfg_eth0_sel=' selected' ;;
	eth1) webcfg_eth1_sel=' selected' ;;
	usbrndis) webcfg_usb_sel=' selected' ;;
	tiwlan) webcfg_wlan_sel=' selected' ;;
esac

ifilt_eth0_sel=''
ifilt_eth1_sel=''
ifilt_usb_sel=''
ifilt_wlan_sel=''

case "$FIREWALL_IFILT_IF" in
	eth0) ifilt_eth0_sel=' selected' ;;
	eth1) ifilt_eth1_sel=' selected' ;;
	usbrndis) ifilt_usb_sel=' selected' ;;
	tiwlan) ifilt_wlan_sel=' selected' ;;
esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin 'Whitelist'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=whitelist">$(lang de:"Whitelist bearbeiten" en:"Edit whitelist")</a></li>
</ul>
EOF

sec_end
sec_begin '$(lang de:"Optionen" en:"Settings")'

cat << EOF
<p>
<input type="hidden" name="log" value="no">
<input id="l1" type="checkbox" name="log" value="yes"$log_chk><label for="l1"> $(lang de:"Verbindungen loggen" en:"Log connections")</label>
</p>
<h2>$(lang de:"Zugriff auf die Box" en:"Access to the box")</h2>
<p style="font-size:10px;">$(lang de:"Diese Optionen sind nur wirksam, wenn &quot;Alle Computer befinden sich im selben IP-Netzwerk&quot; deaktiviert ist, und werden erst 5 Minuten nach dem Start der Box aktiv. Die Liste von Netzwerk Schnittstellen ist nur eine Auswahl m&ouml;glicher, aber nicht notwendigerweise vorhandener Schnittstellen." en:"These settings are not effective, if &quot;All computers are on the same network&quot; is enabled, and take effect 5 minutes after booting. The list of network interfaces is only a choice of possible interfaces, but they need not be existing ones.")</p>
<p>
<input type="hidden" name="webcfg" value="no">
<input id="w1" type="checkbox" name="webcfg" value="yes"$webcfg_chk><label for="w1"> $(lang de:"Webinterface nur &uuml;ber" en:"Restrict webinterface to")</label> <select name="webcfg_if">
<option value="eth0"$webcfg_eth0_sel>LAN A</option>
<option value="eth1"$webcfg_eth1_sel>LAN B</option>
<option value="usbrndis"$webcfg_usb_sel>USB</option>
<option value="tiwlan"$webcfg_wlan_sel>WLAN</option>
</select>$(lang de:" zug&auml;nglich machen" en:"")
</p>
<p>$(lang de:"Drop Prefix" en:"Drop prefix"): <input type="text" name="webcfg_log_prefix" size="16" maxlength="255" value="$(httpd -e "$FIREWALL_WEBCFG_LOG_PREFIX")"></p>
<p>
<input type="hidden" name="ifilt" value="no">
<input id="f1" type="checkbox" name="ifilt" value="yes"$ifilt_chk><label for="f1"> $(lang de:"Dienste auf der Box, die an die folgenden Ports gebunden sind, nur &uuml;ber" en:"Restrict services, which listen on the following ports, to")</label> <select name="ifilt_if">
<option value="eth0"$ifilt_eth0_sel>LAN A</option>
<option value="eth1"$ifilt_eth1_sel>LAN B</option>
<option value="usbrndis"$ifilt_usb_sel>USB</option>
<option value="tiwlan"$ifilt_wlan_sel>WLAN</option>
</select>$(lang de:" zug&auml;nglich machen" en:"")
</p>
<p>Ports: <input type="text" name="ifilt_ports" size="20" maxlength="255" value="$(httpd -e "$FIREWALL_IFILT_PORTS")"></p>
<p>$(lang de:"Drop Prefix" en:"Drop prefix"): <input type="text" name="ifilt_log_prefix" size="16" maxlength="255" value="$(httpd -e "$FIREWALL_IFILT_LOG_PREFIX")"></p>
<h2>$(lang de:"Zugriff auf das Internet" en:"Access to the internet")</h2>
<p style="font-size:10px;">$(lang de:"Hierf&uuml;r wird die Whitelist angewandt. Wenn &quot;Alle Computer befinden sich im selben IP-Netzwerk&quot; deaktiviert ist, so gelten die Regeln auch f&uuml;r Datenverkehr zwischen den internen Netzwerk Schnittstellen." en:"Filtering is done using the whitelist. If &quot;All computers are on the same network&quot; is disabled, then the rules also apply for traffic between internal network interfaces.")</p>
<p>
<input type="hidden" name="icmp" value="no">
<input id="i1" type="checkbox" name="icmp" value="yes"$icmp_chk><label for="i1"> $(lang de:"ICMP f&uuml;r Whitelist erlauben" en:"Allow ICMP for whitelist")</label>
</p>
<p>
<input type="hidden" name="hosts" value="no">
<input id="h1" type="checkbox" name="hosts" value="yes"$hosts_chk><label for="h1"> $(lang de:"<a href=\"/cgi-bin/file.cgi?id=exhosts\">Hosts</a> mit folgenden Parametern in Whitelist aufnehmen" en:"Append <a href=\"/cgi-bin/file.cgi?id=exhosts\">Hosts</a> to the whitelist using the following settings")</label>
</p>
<p>Ports: <input type="text" name="hosts_ports" size="20" maxlength="255" value="$(httpd -e "$FIREWALL_HOSTS_PORTS")"></p>
<p>$(lang de:"Log Prefix" en:"Log prefix"): <input type="text" name="hosts_log_prefix" size="16" maxlength="255" value="$(httpd -e "$FIREWALL_HOSTS_LOG_PREFIX")"></p>
EOF

sec_end
