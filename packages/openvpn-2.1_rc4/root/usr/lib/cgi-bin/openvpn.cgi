#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
client_chk=''; server_chk=''
tcp_chk=''; udp_chk='';
keep_chk=''; tun_chk=''; 
tap_chk=''; static_chk=''; 
certs_chk=''; redir_chk=''; 
client2client_chk=''; bf_chk=''; 
aes128_chk=''; aes256_chk='';
des3_chk=''; float_chk=''; logfile_chk='';
dhcpclient_chk=''; pull_chk=''; tlsauth_chk='';

if [ "$OPENVPN_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$OPENVPN_MODE" = "server" ]; then server_chk=' checked'; else client_chk=' checked'; fi
if [ "$OPENVPN_PROTO" = "udp" ]; then udp_chk=' checked'; else tcp_chk=' checked'; fi
if [ "$OPENVPN_KEEPALIVE" = "yes" ]; then keep_chk=' checked'; fi
if [ "$OPENVPN_TYPE" = "tap" ]; then tap_chk=' checked'; else tun_chk=' checked'; fi
if [ "$OPENVPN_AUTH_TYPE" = "certs" ]; then certs_chk=' checked'; else static_chk=' checked'; fi
if [ "$OPENVPN_PUSH_REDIRECT" = "yes" ]; then redir_chk=' checked'; fi
if [ "$OPENVPN_CLIENT2CLIENT" = "yes" ]; then client2client_chk=' checked'; fi
if [ "$OPENVPN_FLOAT" = "yes" ]; then float_chk=' checked'; fi
if [ "$OPENVPN_LOGFILE" = "yes" ]; then logfile_chk=' checked'; fi
if [ "$OPENVPN_DHCP_CLIENT" = "yes" ]; then dhcpclient_chk=' checked'; fi
if [ "$OPENVPN_PULL" = "yes" ]; then pull_chk=' checked'; fi
if [ "$OPENVPN_TLS_AUTH" = "yes" ]; then tlsauth_chk=' checked'; fi

case "$OPENVPN_CIPHER" in
	AES-128-CBC) aes128_chk=' selected' ;;
	AES-256-CBC) aes256_chk=' selected' ;;
	DES-EDE3-CBC) des3_chk=' selected' ;;
	*) bf_chk=' selected' ;;
esac

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>$(lang de:"Starttyp" en:"Start type")<br /><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label> <input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label></p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Configuration")'

cat << EOF
<p>$(lang de:"OpenVPN als Server oder als Client?" en:"Use OpenVPN as a server or a client?"): <input id="m1" type="radio" name="mode" value="server" onclick="changemode('server')" $server_chk><label for="m1"> $(lang de:"Server" en:"server")</label>&nbsp;<input id="m2" type="radio" name="mode" value="client" onclick="changemode('client')" $client_chk><label for="m2"> $(lang de:"Client" en:"client")</label></p>
<p>$(lang de:"UDP oder TCP Protokoll?" en:"Protocol type UDP or TCP?"): <input id="m3" type="radio" name="proto" value="udp"$udp_chk><label for="m3"> $(lang de:"UDP" en:"UDP")</label>&nbsp;<input id="m4" type="radio" name="proto" value="tcp"$tcp_chk><label for="m4"> $(lang de:"TCP" en:"TCP")</label></p>
<p>$(lang de:"Port" en:"Port"): <input id="port" type="text" size="4" maxlength="5" name="port" value="$(httpd -e "$OPENVPN_PORT")"> $(lang de:"Lokale Adresse" en:"Local Address") (optional): <input id="local" type="text" size="12" maxlength="16" name="local" value="$(httpd -e "$OPENVPN_LOCAL")"></p>
<p>$(lang de:"Modus" en:"Mode"): <input id="m5" type="radio" name="type" value="tun" onclick="changetype('tun')"$tun_chk><label for="m5"> Tunnel (TUN)</label>&nbsp;<input id="m6" type="radio" name="type" value="tap" onclick="changetype('tap')"$tap_chk><label for="m6"> $(lang de:"Br&uuml;cke" en:"Bridge") (TAP)</label></p>
EOF

sec_end
sec_begin '$(lang de:"Sicherheit" en:"Security")'

cat << EOF
<p>$(lang de:"Authentifizierungsmethode" en:"Authentification Type"): <input id="m7" type="radio" name="auth_type" value="static" onclick="changeauth('static')"$static_chk><label for="m7"> $(lang de:"statisch" en:"static")</label>&nbsp;<input id="m8" type="radio" name="auth_type" value="certs" onclick="changeauth('certs')"$certs_chk><label for="m8"> $(lang de:"Zertifikate" en:"Certificates")</label></p>
<p>Cipher: <select id="cipher" name="cipher"><option value="BF-CBC"$bf_chk>Blowfish</option><option value="AES-128-CBC"$aes128_chk>AES 128</option><option value="AES-256-CBC"$aes256_chk>AES 256</option><option value="DES-EDE3-CBC"$des3_chk>Triple-DES</option></select><br /><small>$(lang de:"Muss auf Server <b>und</b> Client identisch sein" en:"Must be equal on server <b>and</b> client")</small></p>
<div id="div_tls">
<p><input type="hidden" name="tls_auth" value=""><input id="k10" type="checkbox" name="tls_auth" value="yes"$tlsauth_chk><label for="k10">TLS-$(lang de:"Authentifizierung (nur mit Zertifikaten)" en:"Auth (only when used with certificates)")</label>
</div>
EOF

sec_end
sec_begin '$(lang de:"IP-Adressen" en:"IP-Addresses")'

cat << EOF
<h2>$(lang de:"Lokaler Endpunkt" en:"Local endpoint")</h2>
<p>$(lang de:"IP-Adresse" en:"IP-Address"): <input id="box_ip" size="12" maxlength="16" type="text" name="box_ip" value="$(httpd -e "$OPENVPN_BOX_IP")"> $(lang de:"Subnetzmaske" en:"Subnet Mask"): <input id="box_mask" size="12" maxlength="16" type="text" name="box_mask" value="$(httpd -e "$OPENVPN_BOX_MASK")"></p>
<div id="div_endpoint">
<h2>$(lang de:"Entfernter Endpunkt (nur f&uuml;r" en:"Remote endpoint (only for") TUN)</h2>
<p>$(lang de:"IP-Adresse" en:"IP-Address"): <input id="remote_ip" size="12" maxlength="16" type="text" name="remote_ip" value="$(httpd -e "$OPENVPN_REMOTE_IP")"></p>
<div id="div_vpn">
<h2>$(lang de:"Netzwerksegment (nur f&uuml;r" en:"Network segment (only for") TUN-Server)</h2>
<p><input id="vpn_net" type="text" size="30" maxlength="33" name="vpn_net" value="$(httpd -e "$OPENVPN_VPN_NET")"><br /><small>Syntax: &lt;ip&gt; &lt;subnetmask&gt;</small></p>
</div>
</div>
EOF

sec_end
sec_begin 'Routing (optional)'

cat << EOF
<p>$(lang de:"Lokales Netzwerk" en:"Local Network Address"): <input id="local_net" size="30" maxlength="33" type="text" name="local_net" value="$(httpd -e "$OPENVPN_LOCAL_NET")"><br /><small>Syntax: &lt;ip&gt; &lt;subnetmask&gt;</small></p>
<p>$(lang de:"Entferntes Netzwerk" en:"Network Address"): <input id="remote_net" size="30" maxlength="33" type="text" name="remote_net" value="$(httpd -e "$OPENVPN_REMOTE_NET")"><br /><small>Syntax: &lt;ip&gt; &lt;subnetmask&gt;</small></p>
EOF

sec_end
sec_begin '$(lang de:"Server-Einstellungen" en:"Server Configuration")'

cat << EOF
<div id="div_dhcp">
<p>$(lang de:"Client Adressbereich (nur mit Zertifikaten)" en:"Client Address Range (only when used with Certs)"):<br /><input id="dhcp_range" type="text" size="30" maxlength="33" name="dhcp_range" value="$(httpd -e "$OPENVPN_DHCP_RANGE")"><br /><small>Syntax: &lt;start-ip&gt; &lt;end-ip&gt;</small></p>
</div>
<p>Max. Clients: <input id="maxclients" type="text" size="4" maxlength="3" name="maxclients" value="$(httpd -e "$OPENVPN_MAXCLIENTS")"></p>
<h2>Push $(lang de:"Optionen" en:"Options") (optional)</h2>
<p>DNS Server: <input id="push_dns" type="text" maxlength="16" name="push_dns" value="$(httpd -e "$OPENVPN_PUSH_DNS")"></p>
<p>WINS Server: <input id="push_wins" type="text" maxlength="16" name="push_wins" value="$(httpd -e "$OPENVPN_PUSH_WINS")"></p>
<p><input type="hidden" name="push_redirect" value=""><input id="k3" type="checkbox" name="push_redirect" value="yes"$redir_chk><label for="k3">$(lang de:"Client Traffic umleiten" en:"Redirect client Traffic")</label></p>
<p><input type="hidden" name="client2client" value=""><input id="k4" type="checkbox" name="client2client" value="yes"$client2client_chk><label for="k4">$(lang de:"Clients d&uuml;rfen untereinader kommunizieren" en:"Clients may communicate to each other")</label></p>
EOF

sec_end
sec_begin '$(lang de:"Client-Einstellungen" en:"Client Configuration")'

cat << EOF
<p>Server: <input id="remote" type="text" name="remote" value="$(httpd -e "$OPENVPN_REMOTE")"><br /><small>Server $(lang de:"Hostname oder IP-Adresse" en:"Hostname or IP-Address")</small></p>
<div id="div_client_dhcp">
<p><input type="hidden" name="dhcp_client" value=""><input id="k9" type="checkbox" name="dhcp_client" value="yes"$dhcpclient_chk><label for="k9">$(lang de:"IP-Adresse vom Server empfangen (nur " en:"Recieve IP Address from the Server (only for") TAP)</label></p>
</div>
<div id="div_client_pull">
<p><input type="hidden" name="pull" value=""><input id="k7" type="checkbox" name="pull" value="yes"$pull_chk><label for="k7">$(lang de:"Optionen vom Server empfangen (nur mit Zertifikaten)" en:"Pull options from Server (only when used with certificates)")</label></p>
</div>
EOF

sec_end
sec_begin '$(lang de:"Optionen" en:"Options")'

cat << EOF
<p><input type="hidden" name="keepalive" value=""><input id="k1" type="checkbox" name="keepalive" value="yes"$keep_chk><label for="k1"> $(lang de:"Verbindung aufrechterhalten" en:"Keep connection")</label></p>
<p><input type="hidden" name="float" value=""><input id="k5" type="checkbox" name="float" value="yes"$float_chk><label for="k5">$(lang de:"Erlaube IP-&Auml;nderungen f&uuml;r entfernte Hosts" en:"Allow ip address changes of remote hosts")</label></p>
<p>$(lang de:"Bandbreitenbegrenzung" en:"Traffic Shaping") (optional): <input id="shaper" type="text" name="shaper" size="4" maxlength="5" value="$(httpd -e "$OPENVPN_SHAPER")"><br /><small>B/s (Bytes $(lang de:"pro Sekunde" en:"per second"))</small></p>
<p><input type="hidden" name="logfile" value=""><input id="k8" type="checkbox" name="logfile" value="yes"$logfile_chk><label for="k8">$(lang de:"Verbindungen protokollieren" en:"Log connections")</label></p>
<script>
FIELDSET_SERVER = 5
FIELDSET_CLIENT = 6
function changemode(value) {
  if(!document.getElementsByTagName) return;
  if(window.opera) return;
  var fieldsets = document.getElementsByTagName("fieldset");
	switch (value) {
		case "server":
			fieldsets[FIELDSET_SERVER].style.display = "block";
			fieldsets[FIELDSET_CLIENT].style.display = "none";
			document.getElementById("div_vpn").style.display = "block";
			document.getElementById("div_dhcp").style.display = "block";
			break;
		case "client":
			fieldsets[FIELDSET_SERVER].style.display = "none";
			fieldsets[FIELDSET_CLIENT].style.display = "block";
			document.getElementById("div_vpn").style.display = "none";
			document.getElementById("div_dhcp").style.display = "none";
			break;
	}
}
function changetype(value) {
  if(!document.getElementsByTagName) return;
  if(window.opera) return;
	switch (value) {
		case "tun":
			document.getElementById("div_endpoint").style.display = "block";
			document.getElementById("div_client_dhcp").style.display = "none";
			break;
		case "tap":
			document.getElementById("div_endpoint").style.display = "none";
			document.getElementById("div_client_dhcp").style.display = "block";
			break;
	}
}
function changeauth(value) {
  if(!document.getElementsByTagName) return;
  if(window.opera) return;
	switch (value) {
		case "static":
			document.getElementById("div_tls").style.display = "none";
			document.getElementById("div_dhcp").style.display = "none";
			document.getElementById("div_client_pull").style.display = "none";
			break;
		case "certs":
			document.getElementById("div_tls").style.display = "block";
			document.getElementById("div_dhcp").style.display = "block";
			document.getElementById("div_client_pull").style.display = "block";
			break;
	}
}
changemode('$OPENVPN_MODE');
changetype('$OPENVPN_TYPE');
changeauth('$OPENVPN_AUTH_TYPE');
</script>
EOF

sec_end
