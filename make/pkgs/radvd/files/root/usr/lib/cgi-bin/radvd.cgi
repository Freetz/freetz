#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$RADVD_FORWARD" yes:forward
check "$RADVD_SETIPV6" yes:setipv6
check "$RADVD_SETMANAGED" yes:setmanaged
check "$RADVD_SETOTHER" yes:setother

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$RADVD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"radvd" en:"radvd")"

cat << EOF
<table border="0">
<tr>
	<td>$(lang de:"IPv6 Schnittstelle" en:"IPv6 interface"):</td>
	<td><input type="text" name="interface" size="15" maxlength="16" value="$(html "$RADVD_INTERFACE")"></td>
</tr>
<tr>
	<td>$(lang de:"IPv6 Adresse" en:"IPv6 address"):</td>
	<td><input type="text" name="address" size="30" maxlength="100" value="$(html "$RADVD_ADDRESS")"></td>
</tr>
<tr>
	<td>$(lang de:"IPv6 Prefix" en:"IPv6 prefix"):</td>
	<td><input type="text" name="prefix" size="30" maxlength="100" value="$(html "$RADVD_PREFIX")"></td>
</tr>
<tr>
	<td>$(lang de:"IPv6 MTU" en:"IPv6 MTU"):</td>
	<td><input type="text" name="mtu" size="9" maxlength="9" value="$(html "$RADVD_MTU")"></td>
</tr>
</table>
<p>
<input type="hidden" name="forward" value="no">
<input id="c1" type="checkbox" name="forward" value="yes"$forward_chk>
<label for="c1">$(lang de:"IPv6 Forwarding im Kernel aktivieren beim Starten bzw deaktivieren beim Stoppen." en:"Activate on start resp. deactivate on stop the IPv6 forwarding.")</label>
</p>
EOF

if [ "$FREETZ_PACKAGE_RADVD_VERSION_ABANDON" = "y" ]; then
cat << EOF
<p>
<input type="hidden" name="setipv6" value="no">
<input id="c2" type="checkbox" name="setipv6" value="yes"$setipv6_chk>
<label for="c2">$(lang de:"IPv6 Adresse der Schnittstelle setzen beim Starten bzw. entfernen beim Stoppen." en:"Set on start resp. unset on stop the IPv6 address of the interface.")</label>
</p>
EOF
fi

cat << EOF
<p>
<input type="hidden" name="setmanaged" value="no">
<input id="c3" type="checkbox" name="setmanaged" value="yes"$setmanaged_chk>
<label for="c3">$(lang de:"Das IPv6-Subnetz als verwaltet markieren" en:"Mark IPv6 subnet as managed")</label>
</p>
<p>
<input type="hidden" name="setother" value="no">
<input id="c4" type="checkbox" name="setother" value="yes"$setother_chk>
<label for="c4">$(lang de:"Andere Konfiguration aus dem Netzwerk anfordern" en:"Request other config from the network")</label>
</p>
EOF

sec_end

sec_begin "$(lang de:"Optionale Parameter" en:"Optional parameters")"
cat << EOF
$(lang de:"Leerzeichen getrennte Liste der Clients an die es erlaubt ist Prefixe anzuk&uuml;ndigen" en:"A space separated list of clients (IPv6 addresses) to advertise to"):
<input type="text" name="clients" size="55" maxlength="255" value="$(html "$RADVD_CLIENTS")">
<br>
$(lang de:"DNS-Server (mit Leerzeichen getrennt)" en:"DNS server list (separated by spaces)"):
<input type="text" name="RDNS" size="55" maxlength="255" value="$(html "$RADVD_RDNS")">
<br>
$(lang de:"DNS-Suchdomains" en:"DNS domain search list"):
<input type="text" name="DNSSL" size="55" maxlength="255" value="$(html "$RADVD_DNSSL")">
EOF
sec_end
