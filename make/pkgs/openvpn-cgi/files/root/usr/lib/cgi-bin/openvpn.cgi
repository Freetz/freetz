#!/bin/sh


. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

MYVARS='AUTOSTART DEBUG DEBUG_TIME LOCAL MODE REMOTE PORT PROTO IPV6 TYPE BOX_IP BOX_MASK REMOTE_IP DHCP_RANGE LOCAL_NET REMOTE_NET DHCP_CLIENT MTU AUTH_TYPE CIPHER TLS_AUTH FLOAT KEEPALIVE KEEPALIVE_PING KEEPALIVE_TIMEOUT COMPLZO MAXCLIENTS CLIENT2CLIENT PUSH_DOMAIN PUSH_DNS PUSH_WINS REDIRECT VERBOSE SHAPER UDP_FRAGMENT PULL LOGFILE MGMNT CLIENTS_DEFINED CLIENT_INFO CLIENT_IPS CLIENT_NAMES CLIENT_NETS CLIENT_MASKS CONFIG_NAMES ADDITIONAL OWN_KEYS NO_CERTTYPE TAP2LAN FILES2CP PARAM_1 PARAM_2 PARAM_3'
ALLVARS="$MYVARS ENABLED CONFIG_COUNT CONFIG_CHANGED LOADTUN EXPERT"

#if which openvpn >/dev/null; then
#	HASBLOWFISH=$(openvpn --show-ciphers | grep -q BF-CBC && echo true)
#	HASLZO=$(openvpn --version | grep -q LZO && echo true)
#else
	HASBLOWFISH=$([ "$FREETZ_PACKAGE_OPENVPN_WITH_BLOWFISH" == y ] && echo true)
	HASLZO=$([ "$FREETZ_PACKAGE_OPENVPN_WITH_LZO" == y ] && echo true)
#fi

cat << EOF
<style type="text/css">
	span.small, div.small {
		font-size:0.8em;
		line-height:1.25em;
	}
	table.padded td {
		padding:5px;
	}
	div#div_expert div.label {
		width:375px;
		float:left;
		clear:both;
		text-align:right;
		line-height:30px;
	}
	div#div_expert div.textbox {
		float:left;
		line-height:30px;
		vertical-align:middle;
	}
	div#div_expert div.textbox:before {
		content:"\00A0";
	}
	div#srv_conf_cert div.label,
	div#div_ip_settings div.label {
		width:200px;
		float:left;
		clear:both;
		text-align:right;
		line-height:30px;
	}
	div#srv_conf_cert div.textbox,
	div#div_ip_settings div.textbox {
		float:left;
		line-height:30px;
		vertical-align:middle;
	}
	div#srv_conf_cert div.textbox:before,
	div#div_ip_settings div.textbox:before {
		content:"\00A0";
	}
</style>
EOF

sec_begin "$(lang de:"Bemerkung" en:"Remark")" sec-remark

cat << EOF
<p>
$(lang \
  de:"Die meisten Textboxen, Checkboxen, Buttons etc. bieten hilfreiche \"MouseOver-Texte\" (mit Maus auf ein Objekt zeigen und halten) an, die beim Vestehen einer Einstellungen n&uuml;tzlich sind!" \
  en:"Most text boxes, check boxes, buttons etc. are equipped with helpful mouseover texts (point to object with mouse and hold) which help understand a particular setting." \
)
</p>
EOF

sec_end

sec_begin "$(lang de:"Konfigurationsverwaltung" en:"Multiple Configurations")" sec-conf

cat << EOF
<table class="padded" style="float:left;">
<tr>
	<td colspan="2" align="center">
	  <b>$(lang de:"Konfiguration w&auml;hlen/l&ouml;schen" en:"Select/Delete configuration"):</b>
	</td>
</tr>
<tr>
	<td>
	  <select id="id_act_config" name="my_config" size="1" style="width:150px;" onchange="changeconf()">
		<option value="1">default</option>
	  </select>
	</td>
	<td>
	  <input type="button" value="$(lang de:"L&ouml;schen" en:"Delete")" style="width:150px;" title=$(lang de:"\'Diese Konfiguration l&ouml;schen (nicht m&ouml;glich f&uuml;r \"default\")\'" en:"\'Delete this configuration (not possible for \"default\")\'") onclick='if (local_config_count > 1) del_config(); else alert("$(lang de:"Das ist die letze Konfiguration und kann daher nicht entfernt werden!" en:"This is the last configuration and therefor cannot be deleted!")");'>
	</td>
</tr>
</table>
<table class="padded" style="float:left; margin-left:20px;">
<tr>
	<td colspan="2" align="center">
	  <b>$(lang de:"Eine neue Konfiguration hinzuf&uuml;gen" en:"Add a new configuration"):</b><br>
	</td>
</tr>
<tr>
	<td>
	  <input type="text" style="width:150px;" maxlength="12" title=$(lang de:"\'Eine kurze Bezeichnung f&uuml;r die neue Konfiguration (z.B. \"Buero\" oder \"zu_Franz\")\'" en:"\'Short name for the new configuration e.g. \"office\" or \"notebook\"\'") id="id_act_config_name">
	</td>
	<td>
	  <input type="button" value="$(lang de:"Hinzuf&uuml;gen" en:"Add")" style="width:150px;" title=$(lang de:"\'Neue Konfiguration mit angegebenem Namen hinzuf&uuml;gen\'" en:"\'Add a new configuration with specified name\'" ) onclick="add_config();">
	</td>
</tr>
</table>
<div style="clear:both;"></div>
EOF

sec_end

echo "<script> document.getElementById('sec-conf').style.display = 'none';</script>"

sec_begin "$(lang de:"Starttyp" en:"Start type")"

# build hidden input fields
for var in $ALLVARS; do
small=$(echo $var | tr 'A-Z' 'a-z')
echo '<input type="hidden" id="id_'$small'" name="'$small'" value='"'"$(eval echo "\$OPENVPN_$var")"'"'>'
done

cat << EOF
<table class="padded">
<tr>
	<td>
	  <input id="id_act_start_auto" type="radio" name="my_enabled" onclick='(local_autostart[act_conf]="yes"); changeval();'>
	  <label for="id_act_start_auto">$(lang de:"Automatisch" en:"Automatic")</label>
	</td>
	<td>
	  <input id="id_act_start_man" type="radio" name="my_enabled" onclick='(local_autostart[act_conf]=""); changeval();'>
	  <label for="id_act_start_man">$(lang de:"Manuell" en:"Manual")</label>
	</td>
	<td>
EOF
if [ -e "/mod/etc/default.inetd/inetd.cfg" -a $OPENVPN_CONFIG_COUNT -le 1 ]; then
cat << EOF
	  <input id="id_act_start_inet" type="radio" name="my_enabled" onclick='(local_autostart[act_conf]="inetd"); changeval();'>
	  <label for="id_act_start_inet">Inetd</label>
EOF
fi
cat << EOF
	</td>
</tr>
<tr>
	<td colspan="3">
	  <input id="id_is_loadtun" type="checkbox" onclick='if (this.checked) (local_loadtun="yes"); else (local_loadtun=""); changeval();'>
	  <label for="id_is_loadtun">$(lang de:"Lade das tun Modul (und falls vorhanden yf_patchkernel) automatisch" en:"Load the tun module (and if available yf_patchkernel) automatically")</label>
	</td>
</tr>
<tr>
	<td colspan="3">
	  <input id="id_act_debug" title="$(lang de:"Ausgaben protokollieren nach " en:"Save messages to ") &quot;var/tmp/debug_openvpn.out&quot;" type="checkbox" onclick='if (this.checked) (local_debug[act_conf]="yes"); else (local_debug[act_conf]=""); changeval();'>
	  <label for="id_act_debug">$(lang de:"Debug-Mode aktivieren" en:"Enable debug mode") (/var/tmp/debug_openvpn.out)</label>

	  <div id="div_debug" style="padding-top:10px; margin-left:10px;">
		$(lang de:"\"Ausf&uuml;rlichkeit\" des Logs" en:"Verbosity of the Log") (Verb-Level):&nbsp;
		<input id="id_act_verbose" type="text" title="$(lang de:"&quot;Geschw&auml;tzigkeit&quot;: Normal=3, &quot;R/W&quot; pro Paket=5, Ausf&uuml;hrlich=6, &quot;alles&quot;=11" en:"Verbosity: usual=3, &quot;R/W&quot; per paket=5, detailed=6, &quot;everything&quot;=11")" size="2" maxlength="2" onblur='(local_verbose[act_conf]=this.value); Consolidate_Vars();'><br>
		<span class="small">
		  $(lang de:"<b>!Stoppen des Dienstes nach einiger Zeit nicht vergessen!</b><br> Das Dateisystem l&auml;uft sonst schnell &uuml;ber!" en:"<b>!Don\'t forget to stop the daemon after some time!</b><br>(To prevent filesystem overflow.)")<br>
		  $(lang de:"Die Log-Datei wird beim n&auml;chsten Start ohne Debug-Mode gel&ouml;scht." en:"Log file will be deleted next start w/o debug mode.")
		</span>
	  </div>
	</td>
</tr>
</table>
EOF

sec_end

sec_begin "$(lang de:"Basiseinstellungen" en:"Basic Configuration")"

cat << EOF
<table class="padded">
<tr>
	<td>
	  <input id="id_act_server" type="radio" name="my_mode" onclick='(local_mode[act_conf]="server"); changeval();'>
	  <label for="id_act_server">Server</label>
	</td>
	<td>
	  <input id="id_act_client" type="radio" name="my_mode" onclick='(local_mode[act_conf]="client"); changeval();'>
	  <label for="id_act_client">Client</label>
	</td>
	<td style="width:60px;">
	  &nbsp;
	</td>
	<td>
	  <input id="id_act_tun" type="radio" name="my_type" value="tun" onclick='(local_type[act_conf]="tun"); $(echo 'document.getElementById("div_add_tap").style.display=(this.checked)? "none" : "block";') changeval();'>
	  <label for="id_act_tun">Tunnel (TUN)</label>
	</td>
	<td>
	  <input id="id_act_tap" type="radio" name="my_type" value="tap" onclick='(local_type[act_conf]="tap"); $(echo 'document.getElementById("div_add_tap").style.display=(this.checked)? "block" : "none";') changeval();'>
	  <label for="id_act_tap">$(lang de:"Br&uuml;cke" en:"Bridge") (TAP)</label>
	</td>
</tr>
<tr>
	<td>
	  <input id="id_act_udp" type="radio" name="my_proto" value="udp" onclick='(local_proto[act_conf]="udp"); Consolidate_Vars()'>
	  <label for="id_act_udp">UDP</label>
	</td>
	<td>
	  <input id="id_act_tcp" type="radio" name="my_proto" value="tcp" onclick='(local_proto[act_conf]="tcp"); Consolidate_Vars()'>
	  <label for="id_act_tcp">TCP</label>
	</td>
	<td>
	  &nbsp;
	</td>
	<td align="center">
	  <div id="div_port" style="display:inline;">
		Port:&nbsp;<input id="id_act_port" type="text" title="$(lang de:"Port, auf dem der Server auf Verbindungsw&uuml;nsche &quot;lauscht&quot;" en:"Server is listening for incoming requests on this port")" size="5" maxlength="5" onblur='(local_port[act_conf]=this.value); Consolidate_Vars()'>
	  </div>
	</td>
	<td>
	  <div id="div_add_tap">
		<select id="id_act_tap2lan" title="$(lang de:"Das TAP-Interface wird automatisch zum LAN-Interface gebr&uuml;ckt (brctl). LAN-IP ignoriert die eingegebene IP und nutzt die IP des LAN Interfaces" en:"TAP interface will be bridged to LAN using brctl. LAN IP will ignore the local IP and use the IP of the interface lan.")" name="my_tap2lan" onchange='local_tap2lan[act_conf]=this.value; changeval();'>
		<option value="">$(lang de:"tap nicht br&uuml;cken" en:"don't bridge tap")</option>
		<option value="yes">$(lang de:"mit LAN br&uuml;cken" en:"bridge to LAN")</option>
		<option value="uselanip">$(lang de:"br&uuml;cken und LAN-IP nutzen" en:"bridge and use LAN IP")</option>
		</select>
	  </div>
	</td>
</tr>
EOF
if [ "$FREETZ_TARGET_IPV6_SUPPORT" == "y" ]; then cat << CASEEOF
<tr>
	<td colspan="5">
	  <div id="div_use_ipv6">
		<input id="id_act_ipv6" type="checkbox" title="$(lang de:"Verbindung wird &uuml;ber IPv6 hergestellt (als Client) oder OpenVPN kann zus&auml;tzlich &uuml;ber IPv6 erreicht werden (als Server)" en:"Connection will be established via IPv6 (as client) or OpenVPN can additonally be reached via IPv6 (as server)")" name="my_ipv6" value="yes" onclick='(local_ipv6[act_conf]=(this.checked)? "yes" : ""); changeval();'>
		<label for="id_act_ipv6">$(lang de:"IPv6 benutzen" en:"Use IPv6")</label>
	  </div>
	</td>
</tr>
CASEEOF
fi

cat << EOF
<tr>
	<td colspan="5">
	  <div id="div_config_server_off_ip">
		Server $(lang de:"und ggf. Port" en:"and port if needed"):&nbsp;<input id="id_act_remote" type="text" size="30" value="" onblur='(local_remote[act_conf]=this.value); Consolidate_Vars()'><br>
		<div class="small" style="padding-top:7px;">$(lang de:"Server (und Port, falls Port &ne; 1194) z.B. \"10.1.2.3\" oder \"ich.dyndns.org 4711\"" en:"Server (and port if port &ne; 1194) e.g. \"10.1.2.3\" or \"me.dyndns.org 123\"")</div>
	  </div>
	</td>
</tr>
</table>
EOF

sec_end

sec_begin "$(lang de:"Sicherheit" en:"Security")"

cat << EOF
<table class="padded">
<tr>
	<td>
	  $(lang de:"Authentifizierungsmethode" en:"Authentification Method"):<br>
	  <span class="small">$(lang de:"Muss auf Server <b>und</b> Client identisch sein." en:"Must be the same setting on each server <b>and</b> client.")</span>
	</td>
	<td>
	  <input id="id_act_static" type="radio" name="my_auth_type" onclick='(local_auth_type[act_conf]="static"); changeval();'>
	  <label for="id_act_static"> $(lang de:"statischer Schl&uuml;ssel" en:"Static key")</label>
	</td>
	<td>
	  <input id="id_act_certs" type="radio" name="my_auth_type" onclick='(local_auth_type[act_conf]="certs"); changeval();'>
	  <label for="id_act_certs"> $(lang de:"Zertifikate" en:"Certificates")</label>
	</td>
</tr>
<tr>
	<td>
	  Cipher:&nbsp;
	  <select id="id_act_cipher" style="width:150px;" name="my_cipher" onchange='if (this.value=="none") (alert($(lang de:"\"Achtung, Verkehr durch das VPN ist so unverschl\"+unescape(\"%FC\")+\"sselt!\"" en:"\"Caution: All traffic will be unencrypted!\""))); changeval();'>
		$([ $HASBLOWFISH ] && echo '<option value="BF-CBC">Blowfish</option>')
		<option value="AES-128-CBC">AES 128 CBC</option>
		<option value="AES-192-CBC">AES 192 CBC</option>
		<option value="AES-256-CBC">AES 256 CBC</option>
		<option value="AES-128-GCM">AES 128 GCM</option>
		<option value="AES-256-GCM">AES 256 GCM</option>
		<option value="DES-EDE3-CBC">Triple-DES</option>
		<option value="none">$(lang de:"unverschl&uuml;sselt" en:"unencrypted")</option>
	  </select>
	</td>
	<td colspan="2">
	  <div id="div_tls" style="display:inline;">
		<input id="id_act_tls_auth" type="checkbox" name="my_tls_auth" onclick='if (this.checked) (local_tls_auth[act_conf]="yes"); else (local_tls_auth[act_conf]=""); changeval();'>
		<label for="id_act_tls_auth">TLS-$(lang de:"Authentifizierung" en:"Authentication")</label>
	  </div>
	</td>
</tr>
$([ ! $HASBLOWFISH ] && echo "<tr></tr><tr><td colspan="3">$(lang de:"Achtung, Standard-Cipher \"Blowfish\" wird von diesem OpenVPN nicht unterst&uuml;tzt!" en:"Caution! Default cipher \"blowfish\" is not supported by this OpenVPN binary") </td></tr>")
<tr>
	<td colspan="3">
	  <div id="div_no_certtype" style="display:none; padding-top:10px;">
		<input id="id_act_no_certtype" type="checkbox" name="my_no_certtype" title=$(lang de:"\'Auch Zertifikate ohne \"ns-cert-type server\" akzeptieren'" en:"\'Accept server certificates even without \"ns-cert-type server\"'") onclick='if (this.checked) (local_no_certtype[act_conf]="yes"); else (local_no_certtype[act_conf]=""); changeval();'>
		<label for="id_act_no_certtype">$(lang de:"Keine Pr&uuml;fung von " en:"Accept server certificate w/o ") "ns-cert-type"</label>
	  </div>

	  <div id="div_own_keys" style="display:block; padding-top:10px;">
		<input id="id_act_own_keys" type="checkbox" name="my_own_keys" title=$(lang de:"\'Diese Konfiguration ben&ouml;tigt eigene Schl&uuml;ssel/Zertifikate.\'" en:"\'This configuration requires its own key/certificates.\'") onclick='if (this.checked) (local_own_keys[act_conf]="yes"); else (local_own_keys[act_conf]=""); changeval();'>
		<label for="id_act_own_keys">$(lang de:"Eigene Schl&uuml;ssel/Zertifikate f&uuml;r diese Konfiguration" en:"Own key/certificates for this configuration")</label>
	  </div>

	  <div id="div_hide_keys" style="display:block; padding-top:10px; padding-left:30px;">
		<input id="id_act_hide_keys" type="checkbox" title="$(lang de:"Schl&uuml;ssel/Zertifikate nicht im Men&uuml; anzeigen/verlinken (zur &Uuml;bersichtlichkeit)." en:"Hide keys/certificates links in menu (for simplicity's sake)")" name="my_hide_keys" onclick='if (this.checked) (local_own_keys[act_conf]="hidden"); else (local_own_keys[act_conf]="yes"); changeval();'>
		<label for="id_act_hide_keys">$(lang de:"Links zu Schl&uuml;ssel/Zertifikate dieser Konfiguration ausblenden" en:"Hide links to keys/certificates of this configuration")</label>
	  </div>
	</td>
</tr>
</table>
EOF
sec_end

sec_begin "$(lang de:"VPN IP-Adressen und Routing im VPN" en:"VPN IP-Addresses and VPN Routing")" div_ip_settings
cat << EOF
<div class="small" style="padding-bottom:10px;">
$(lang de:"Hier werden die IP-Adressen und das Routing vom VPN konfiguriert." en:"You can configure VPN IP addresses and routing inside the VPN here")
</div>

<div id="div_configure_ip" style="padding-top:10px;">
<div class="label">
	$(lang de:"Lokale IP-Adresse" en:"Local IP-Address"):
</div>
<div class="textbox">
	<input id="id_act_box_ip" title=$(lang de:"\'IP des lokalen VPN Interfaces ( TAP / TUN ), z.B. \"192.168.1.1\" \'" en:"\'IP of local VPN interface ( TAP / TUN ), e.g.\"192.168.1.1\" \'") size="15" maxlength="15" type="text" onblur='(local_box_ip[act_conf]=this.value); Consolidate_Vars();'>
</div>
<div id="div_ip_and_net" style="padding-top:10px;">
	<div class="label">
	  $(lang de:"Netzmaske" en:"Netmask"):
	</div>
	<div class="textbox">
	  <input id="id_act_box_mask" title=$(lang de:"\'Netzmaske f&uuml;r das lokele VPN Interface ( TAP / TUN ), z.B. \"255.255.255.0\" \'" en:"\'Netmask for local VPN interface ( TAP / TUN ), e.g. \"255.255.255.0\" \'") size="15" maxlength="15" type="text" value="" onblur='(local_box_mask[act_conf]=this.value); Consolidate_Vars();'>
	</div>
</div>
<div id="div_ip_loc_rem" style="padding-top:10px;">
	<div class="label">
	  Remote IP-$(lang de:"Adresse" en:"address"):
	</div>
	<div class="textbox">
	  <input id="id_act_remote_ip" title=$(lang de:"\'IP des entfernten VPN Interfaces ( TAP / TUN ), z.B. \"192.168.1.2\" \'" en:"\'IP of remote VPN interface ( TAP / TUN ), e.g. \"192.168.1.2\"\' ") size="15" maxlength="15" type="text" value="" onblur='(local_remote_ip[act_conf]=this.value); Consolidate_Vars();'>
	</div>
</div>
</div>

<div id="div_dhcp" style="min-height:40px; padding-top:10px;">
<div class="label">
	DHCP-Range $(lang de:"f&uuml;r" en:"for") Clients:
</div>
<div class="textbox">
	<input id="id_act_dhcp_range" title=$(lang de:"\'Bereich f&uuml;r Client-IP-Adressen. &nbsp;&nbsp; Syntax: &lt;start-ip&gt; &lt;end-ip&gt;, z.B. \"192.168.1.10 192.168.1.20\"\'" en:"\'Range for Client-IP-addresses. Syntax: &lt;start-ip&gt; &lt;end-ip&gt;, e.g. \"192.168.1.10 192.168.1.20\"\'") type="text" size="31" maxlength="31" value="" onblur='(local_dhcp_range[act_conf]=this.value); Consolidate_Vars();'>
</div>
</div>

<div style="clear:both; padding-top:20px;">
<b>Optional: Routing $(lang de:"von IP-Netzen" en:"of IP networks"):</b>
</div>

<div id="div_set_remote_net" style="padding-top:10px;">
<div class="label">
	$(lang de:"Entferntes Netz" en:"Remote Network"):<br>
</div>
<div class="textbox">
	<input id="id_act_remote_net" size="31" maxlength="100" title="$(lang de:"Dieses Netz wird &uuml;ber VPN zum Client geroutet." en:"This network will be routed to the client through VPN.") &nbsp;&nbsp;Syntax TUN: &lt;ip&gt; &lt;mask&gt; &nbsp; Syntax TAP: &lt;ip&gt; &lt;mask&gt; &lt;gateway&gt;" type="text" onblur='(local_remote_net[act_conf]=this.value); Consolidate_Vars();'>
</div>
</div>

<div id="div_redirect" style="clear:both; padding-top:10px;">
<input id="id_act_redirect" type="checkbox" title="$(lang de:"Alle Pakete des Clients &uuml;ber den VPN-Server umleiten" en:"Redirect all client traffic through VPN")" onclick='if (this.checked) (local_redirect[act_conf]="yes"); else (local_redirect[act_conf]=""); changeval();'>
<label for="id_act_redirect">$(lang de:"Clientverkehr umleiten" en:"Redirect client traffic")</label>
</div>

<div id="div_client_pull" style="padding-top:10px;">
<input id="id_act_pull" type="checkbox" name="my_pull" title=$(lang de:"\'Client empf&auml;ngt Optionen (z.B. Routen), die der Server schickt\'" en:"\'Client receives options (e.g. routes) the server is pushing\'") onclick='if (this.checked) (local_pull[act_conf]="yes"); else (local_pull[act_conf]=""); changeval();'>
<label for="id_act_pull">$(lang de:"Optionen vom Server empfangen" en:"Receive options from server")&nbsp;<span class="small">$(lang de:"(nur mit Zertifikaten)" en:"(only whith certificates)")</span></label>

<div id="div_dhcp_client" style="padding-top:10px; padding-left:30px;">
	<input id="id_act_dhcp_client" type="checkbox" style="vertical-align:top;" title=$(lang de:"\'Die \"push\"-Otionen des Servers enthalten auch die IP f&uuml;r diesen Client\'" en:"\'Server also \"push\"es the IP for this Client\'") onclick='if (this.checked) (local_dhcp_client[act_conf]="yes"); else (local_dhcp_client[act_conf]=""); changeval();'>
	<label for="id_act_dhcp_client"><div style="display:inline-block;">$(lang de:"auch IP-Adresse vom Server empfangen" en:"Also receive client IP-Adresse from server")<br>
	<span class="small">$(lang de:"G&uuml;ltig im Betrieb mit TAP- oder TUN-Server mit &quot;erweiterter Clientkonfiguration&quot;" en:"Valid for use with TAP or TUN server with &quot;Extended client configuration&quot;")</span></div></label>
</div>
</div>

<div id="div_push_local_net" style="padding-top:10px;">
<div class="label">
	$(lang de:"Lokales Netz" en:"Local network"):
</div>
<div class="textbox">
	<input id="id_act_local_net" title="$(lang de:"lokales Netz, Syntax: &lt;ip&gt; &lt;subnetmaske&gt; z.B. &quot;192.168.178.0 255.255.255.0&quot;" en:"Local net, syntax: &lt;ip&gt; &lt;subnetmask&gt; e.g. &quot;192.168.178.0 255.255.255.0&quot;"). $(lang de:"Der Client erh&auml;lt eine Route zu diesem Netz per" en:"Client will receive a network route via") &quot;push&quot;" size="31" maxlength="100" type="text" onblur='(local_local_net[act_conf]=this.value); Consolidate_Vars();'><br>
</div>

<div id="div_allow_clientinfos" style="clear:both; padding-top:10px;">
	<input id="id_act_client_info" type="checkbox" style="vertical-align:top;" name="my_client_info" value="yes" onclick='if (this.checked) (local_client_info[act_conf]="yes"); else (local_client_info[act_conf]=""); changeval();'>
	<label for="id_act_client_info"><div style="display:inline-block;">$(lang de:"Erweiterte Clientkonfiguration" en:"Extended client configuration")<br>
	<span class="small">$(lang de:"Clients feste VPN-IPs zuordnen und Netze zu bestimmten Clients routen" en:"Set static VPN-IPs for clients and route networks to particular clients")</span></div></label>

	<div id="div_client_table" style="padding-top:10px; margin-left:30px;">
	  <input type="button" style="width:150px;" value=$(lang de:"\"Client hinzuf&uuml;gen\"" en:"\"Add Client\"") onclick="addRowToTable('tunclients_table');">
	  <input type="button" style="width:150px;" value=$(lang de:"\"Client entfernen\"" en:"\"Remove client\"") onclick="removeRowFromTable('tunclients_table');">
	  <table id="tunclients_table" class="padded" style="margin-top:10px;">
		<tr id="tunclients">
		  <td>
			$(lang de:"Clientname" en:"Client name") <span class="small"> ($(lang de:"Zertifikat" en:"from certificate"))</span>
		  </td>
		  <td>
			Client-VPN-IP
		  </td>
		  <td>
			$(lang de:"Netz bei Client" en:"Network at client")&nbsp;<span class="small">(Syntax: &lt;ip&gt; &lt;subnetmask&gt;)</span>
		  </td>
		</tr>
	  </table>
	  <div style="padding-top:10px;">
		<b>$(lang de:"Beim Client muss \"pull\" aktiviert sein!" en:"Option \"pull\" must be enabled in client configuration!")</b>&nbsp;(<i>&quot;$(lang de:"Optionen vom Server empfangen" en:"Receive options from server")&quot;</i>)
	  </div>
	</div>
</div>
</div>
<div style="clear:both;"></div>
EOF

sec_end

sec_begin "$(lang de:"Server-Einstellungen (bei Zertifikaten)" en:"Server Configuration (only with certificatess)")" sec-server-conf

cat << EOF
<div id="srv_conf_cert">
<div class="label">
	Max. Clients:
</div>
<div class="textbox">
	<input id="id_act_maxclients" type="text" size="3" maxlength="3" title=$(lang de:"\'Maximale Anzahl Clients, die gleichzeitig verbunden sein d&uuml;rfen\'" en:"\'Maximum number of clients allowed to be connected at once\'") onblur="local_maxclients[act_conf]=this.value; changeval()">
</div>

<div style="clear:both; float:left; padding-top:10px;">
	<input id="id_act_push_redirect" type="checkbox" title=$(lang de:"\'Client anweisen, JEDES Paket &uuml;ber den VPN-Server zu leiten\'" en:"\'Client shall redirect ALL traffic through VPN\'") onclick='if (this.checked) (local_redirect[act_conf]="yes"); else (local_redirect[act_conf]=""); changeval();'>
	<label for="id_act_push_redirect">$(lang de:"Jedes Paket des Clients umleiten" en:"Redirect all clients' traffic")</label>
</div>
<div style="float:left; padding-left:20px; padding-top:10px;">
	<input id="id_act_c2c" type="checkbox" title=$(lang de:"\'Routing zwischen mehreren Clients einrichten; erm&ouml;glicht Zugriff zwischen Clientnetzen\'" en:"\'Enable routing between client networks\'") onclick='if (this.checked) (local_client2client[act_conf]="yes"); else (local_client2client[act_conf]=""); changeval();'>
	<label for="id_act_c2c">Client-$(lang de:"zu" en:"to")-Client</label>
</div>
</div>

<table id="Push_Options" class="padded" style="clear:both; margin-top:10px;">
<tr>
	<td align="center" rowspan="2">
	  <i>Push&nbsp;$(lang de:"Optionen" en:"Options")<br>(optional)</i>
	</td>
	<td>
	  DNS Domain
	</td>
	<td>
	  DNS Server
	</td>
	<td>
	  WINS Server
	</td>
</tr>
<tr>
	<td>
	  <input id="id_act_push_domain" type="text" size="15" maxlength="50" onblur='(local_push_domain[act_conf]=this.value); Consolidate_Vars();'>
	</td>
	<td>
	  <input id="id_act_push_dns" type="text" size="15" maxlength="15" onblur='(local_push_dns[act_conf]=this.value); Consolidate_Vars();'>
	</td>
	<td>
	  <input id="id_act_push_wins" type="text" size="15" maxlength="15" onblur='(local_push_wins[act_conf]=this.value); Consolidate_Vars();'>
	</td>
</tr>
</table>
EOF

sec_end

sec_begin "$(lang de:"Weitere Optionen" en:"Further Options")"

cat << EOF
<div style="display:block;">
<div style="display:inline;">
	<input id="id_act_keepalive" type="checkbox" title="$(lang de:"Zum Aufrechterhalten der Verbindung werden Pings gesendet" en:"Send pings to keep connection alive")" onclick='if (this.checked) (local_keepalive[act_conf]="yes"); else (local_keepalive[act_conf]=""); changeval();'>
	<label for="id_act_keepalive">Keepalive</label>
</div>

<div style="display:inline; padding-left:20px;">
	<input id="id_act_comp_lzo" type="checkbox"
EOF

if [ $HASLZO ]; then
cat << EOF
title="$(lang de:"LZO-Komprimierung nutzen? !!Muss auf Server und Client gleich eingestellt sein!!" en:"Use LZO compression? !!Must be the same setting on server and client site!!")" onclick='if (this.checked) (local_complzo[act_conf]="yes"); else (local_complzo[act_conf]=""); changeval();'
EOF
else
cat << EOF
title="$(lang de:"LZO-Komprimierung nicht eincompiliert." en:"LZO compression not compiled in")" disabled
EOF
fi
cat << EOF
>
	<label for="id_act_comp_lzo">LZO</label>
</div>

<div style="display:inline; padding-left:20px;">
	<input id="id_act_float" type="checkbox" title=$(lang de:"\'Gegenseite darf w&auml;hrend der Verbindung IP &auml;ndern (z.B. bei dynamischer Adresse)\'" en:"\'Remote site may change IP during connection (e.g. when using dynamic IPs)\'") onclick='if (this.checked) (local_float[act_conf]="yes"); else (local_float[act_conf]=""); changeval();'>
	<label for="id_act_float">$(lang de:"IP-&Auml;nderung zulassen" en:"Allow IP change")</label>
</div>

<div style="display:inline; padding-left:20px;">
	<input id="id_act_logfile" type="checkbox" title=$(lang de:"\'Der aktuelle Status der Verbindungen wird in /var/log/openvpn.log protokolliert\'" en:"\'Current status of connection will be logged to /var/log/openvpn.log\'") onclick='if (this.checked) (local_logfile[act_conf]="yes"); else (local_logfile[act_conf]=""); changeval();'>
	<label for="id_act_logfile">$(lang de:"Statusprotokoll" en:"Log status")</label>
</div>
</div>

<div style="display:block; padding-top:10px;">
<input id="id_is_expert" style="vertical-align:top;" type="checkbox" title=$(lang de:"\"Selten ben&ouml;tigte Parameter und Multi-Config-F&auml;higkeit\"" en:"\"Change rarely used settings and enable multiple configs\"") onclick='if (this.checked) (local_expert="yes"); else (local_expert=""); changeval();'>
<label for="id_is_expert"><div style="display:inline-block;">$(lang de:"Experteneinstellungen entsperren / Standardwerte &auml;ndern" en:"Unlock expert settings / edit advanced parameters")<br>
<span class="small">$(lang de:"Ich versichere, folgende Parameter erst nach Lesen der Anleitungen auf \"OpenVPN.net\" zu &auml;ndern ;-)" en:"I herby swear: I will not change any following paramter without prior reading manuals from \"OpenVPN.net\" ;-)")</span></div></label>
</div>

<div id="div_expert" style="padding-left:30px; padding-top:10px;">
<div class="label">
	$(lang de:"Bandbreitenbegrenzung [Bytes/Sekunde]" en:"Bandwidth shaper [Bytes/second]") (optional):
</div>
<div class="textbox">
	<input id="id_act_shaper" type="text" title=$(lang de:"\"Begrenzen der Bandbreite. Erlaubte Werte liegen zwischen 100[Bytes/Sekunde] und 100.000.000[Bytes/Sekunde] (ganze Zahlen eingeben!)\"" en:"\"Bandwidth shaping. Allowed values range from 100[Bytes/second] to 100,000,000[Bytes/second] (put in natural numbers!)\"") name="my_shaper" size="9" maxlength="9" onblur='if (this.value != "" && this.value <100) (this.value=100); if (this.value > 100000000) (this.value=100000000); (local_shaper[act_conf]=this.value); Consolidate_Vars();'>
</div>

<div class="label">
	$(lang de:"Nur an dieser IP-Adresse lauschen" en:"Only listen to this IP-address") (optional):
</div>
<div class="textbox">
	<input id="id_act_local" type="text" value="" title=$(lang de:"\'OpenVPN nimmt nur Verbindungen an diese IP-Adresse an (keine Angabe = &uuml;berall h&ouml;ren)\'" en:"\'OpenVPN only listens on this IP-address (no entry = listen on all IP-addresses)\'") size="15" maxlength="15"  onblur='(local_local[act_conf]=this.value); Consolidate_Vars()'>
</div>

<div class="label">
	$(lang de:"Ping Abstand f&uuml;r Keepalive [Sekunden]" en:"Margin between keepalive pings [seconds]"):
</div>
<div class="textbox">
	<input id="id_act_keepalive_ping" type="text" size="4" maxlength="4" title=$(lang de:"\"Abstand mit dem Keepalive-Pings gesendet werden. Standard = 10[s]\"" en:"\"Interval for keepalive pings. Default = 10[s]\"") onblur='(local_keepalive_ping[act_conf]=this.value); Consolidate_Vars();'>
</div>

<div class="label">
	Keepalive Timeout $(lang de:"[Sekunden]" en:"[seconds]"):
</div>
<div class="textbox">
	<input id="id_act_keepalive_timeout" type="text" size="4" maxlength="4" title=$(lang de:"\"Nach dieser Zeit wird die Verbindung als abgebrochen betrachtet. Standard = 120[s]\"" en:"\"After this period a connection will be treated as broken. Default = 120[s]\"") onblur='(local_keepalive_timeout[act_conf]=this.value); Consolidate_Vars();'>
</div>

<div class="label">
	MTU [Bytes] (optional):
</div>
<div class="textbox">
	<input id="id_act_mtu" type="text" size="4" maxlength="4" title=$(lang de:"\"Maximale Paketgr&ouml;&szlig;e. Bedarf normalerweise keiner &Auml;nderung. Standard = 1500[Bytes]\"" en:"\"Maximum paket size. Usually not subject to change. Default = 1500[Bytes]\"") onblur='(local_mtu[act_conf]=this.value); Consolidate_Vars();'>
</div>

<div class="label">
	$(lang de:"UDP Pakete fragmentieren (nur bei Problemen)" en:"Fragment UDP packets (to solve problems)"):
</div>
<div class="textbox">
	<input id="id_act_udp_fragment" type="text" size="4" maxlength="4" title=$(lang de:"\'Gr&ouml;&szlig;ere UDP-Pakete als hier angegeben immer \"teilen\" (fragmentieren). Vorschlag = 1300[Bytes] (bei MTU = 1500[Bytes])\'" en:"\'Always fragment UDP packets exceeding this length. Proposal = 1300[Bytes] (for MTU = 1500[Bytes])\'") onblur='(local_udp_fragment[act_conf]=this.value); Consolidate_Vars();'>
</div>

<div style="clear:both; padding-top:15px; width:610px; text-align:center;">
	$(lang de:"Zusatzparameter (mit \";\" getrennt), z.B. \"par1 xy ; par2 ab ; par3\"" en:"Additional parameters (separated by \";\"), e.g. \"par1 xy ; par2 ab ; par3\""):<br>
	<input id="id_act_additional" type="text" style="width:600px; margin-top:5px;" onblur='(local_additional[act_conf]=this.value); Consolidate_Vars();'>
</div>
<div style="clear:both; padding-top:15px; width:610px; text-align:center;">
	$(lang de:"Dateien, die ins chroot kopiert werden sollen (mit \";\" trennen)" en:"Files to copy into chroot environment (separate by \";\")"):<br>
	<input id="id_act_files2cp" type="text" style="width:600px; margin-top:5px;" title="$(lang de:"F&uuml;r Programme, die ein Link auf Busybox sind, m&uuml;ssen Link und Busybox kopiert werden!" en:"For busybox commands you will need to copy programm and busybox")"; onblur='(local_files2cp[act_conf]=this.value); Consolidate_Vars();'>
</div>
</div>

<script type="text/javascript">
var ALERT_UNSUPPORTED='$(lang de:" nicht unterst'+unescape(\"%FC\")+'tzt\\n" en:" unsupported\\n")'
var ALERT_START='$(lang de:"Die gespeicherte Konfiguration wird leider nicht unterst'+unescape(\"%FC\")+'tzt.\\n" en:"The saved configuration is not supported by this binary.\\n")'
var ALERT_END='$(lang de:"\\nVor dem Starten bitte eine neue Konfiguration abspeichern!" en:"\\nPlease save a new configuration before starting.")'


var act_conf=1;

variablen=[ "$(echo $MYVARS| sed 's/ /"\, "/ g')" ]

function Init_Vars() {
local_config_count=$OPENVPN_CONFIG_COUNT;
backup_config_count=$OPENVPN_CONFIG_COUNT;
local_loadtun="$OPENVPN_LOADTUN";
local_expert="$OPENVPN_EXPERT";
local_config_changed=new Array();
local_config_changed[0]="new";
for (v=0; v<variablen.length; v++) {
		tmp="local_"+variablen[v].toLowerCase()+'=document.getElementById("id_'+variablen[v].toLowerCase()+'").value.split("#")'
		eval(tmp);
		tmp="backup_"+variablen[v].toLowerCase()+'=document.getElementById("id_'+variablen[v].toLowerCase()+'").value.split("#")'
		eval(tmp);
	}
}

function Consolidate_Vars() {
	document.getElementById("id_config_count").value=local_config_count;
	document.getElementById("id_loadtun").value=local_loadtun;
	document.getElementById("id_expert").value=local_expert;
	document.getElementById("id_enabled").value=local_autostart[1];
	Find_changes();
	document.getElementById("id_config_changed").value=local_config_changed.join("#");
	for (v=0; v<variablen.length; v++) {
		tmp='document.getElementById("id_'+variablen[v].toLowerCase()+'").value=local_'+variablen[v].toLowerCase()+'.join("#")'
		eval(tmp);
	}
}

function Find_changes() {
	for (c=1; c<=local_config_count; c++) { local_config_changed[c] = (c <= backup_config_count)? "" : "new"; }
	for (v=0; v<variablen.length; v++) {
		for (c=1; c<=backup_config_count; c++) {
			tmp="equal=(local_"+variablen[v].toLowerCase()+"["+c+"] == backup_"+variablen[v].toLowerCase()+"["+c+"] )"
			eval(tmp);
			if (!equal) { local_config_changed[c]="yes" }
		 }
	}
}

function changeconf() {
	act_conf= 1 + document.getElementById("id_act_config").selectedIndex;
	Init_Checkbox();
	Init_Table('tunclients_table');
	changeval();
}

function Init_Table(name) {
	var number=Number(local_clients_defined[act_conf]);
	var tbl = document.getElementById(name);
	var lastRow = tbl.rows.length;
	for(j=lastRow;j>1;j--) {
		tbl.deleteRow(j - 1);
	}
	for(j=1;j<=number;j++) {
		addRowToTable(name);
	}
	local_clients_defined[act_conf]=Number(number);
}

function Init_Checkbox() {
alert_lzo = false;
alert_cipher = false;
	if ( local_autostart[act_conf] == "yes" ) { document.getElementById("id_act_start_auto").checked = true } else {
		if ( local_autostart[act_conf] == "inetd" ) { document.getElementById("id_act_start_inet").checked = true } else {document.getElementById("id_act_start_man").checked = true }; }
	if ( local_mode[act_conf] == "server" ) { document.getElementById("id_act_server").checked = true } else { document.getElementById("id_act_client").checked = true };
	if ( local_proto[act_conf] == "tcp" ) { document.getElementById("id_act_tcp").checked = true } else { document.getElementById("id_act_udp").checked = true };
	$([ "$FREETZ_TARGET_IPV6_SUPPORT" == "y" ] && echo "document.getElementById"'("id_act_ipv6").checked = ( local_ipv6[act_conf] == "yes" )? "checked" : ""')
	if ( local_keepalive[act_conf] == "yes" ) { document.getElementById("id_act_keepalive").checked = true } else { document.getElementById("id_act_keepalive").checked = false };
	if ( local_complzo[act_conf] == "yes" ){
		if ( "$(echo $HASLZO)" == "true"  ) { document.getElementById("id_act_comp_lzo").checked = true }
		else { document.getElementById("id_act_comp_lzo").checked = false ; local_complzo[act_conf] = ""; alert_lzo=true;}; }
	else { document.getElementById("id_act_comp_lzo").checked = false };
	if ( local_type[act_conf] == "tap" ) { document.getElementById("id_act_tap").checked = true } else { document.getElementById("id_act_tun").checked = true };
	if ( local_auth_type[act_conf] == "certs" ) { document.getElementById("id_act_certs").checked = true } else { document.getElementById("id_act_static").checked = true };
	if ( local_redirect[act_conf] == "yes" ) { document.getElementById("id_act_redirect").checked = true; document.getElementById("id_act_push_redirect").checked = true } else { document.getElementById("id_act_redirect").checked = false; document.getElementById("id_act_push_redirect").checked = false };
	if ( local_client2client[act_conf] == "yes" ) { document.getElementById("id_act_c2c").checked = true } else { document.getElementById("id_act_c2c").checked = false };
	if ( local_float[act_conf] == "yes" ) { document.getElementById("id_act_float").checked = true } else { document.getElementById("id_act_float").checked = false };
	if ( local_logfile[act_conf] == "yes" ) { document.getElementById("id_act_logfile").checked = true } else { document.getElementById("id_act_logfile").checked = false };
	if ( local_dhcp_client[act_conf] == "yes" ) { document.getElementById("id_act_dhcp_client").checked = true } else { document.getElementById("id_act_dhcp_client").checked = false };
	if ( local_pull[act_conf] == "yes" ) { document.getElementById("id_act_pull").checked = true } else { document.getElementById("id_act_pull").checked = false };
	if ( local_tls_auth[act_conf] == "yes" ) { document.getElementById("id_act_tls_auth").checked = true } else { document.getElementById("id_act_tls_auth").checked = false };
	if ( local_debug[act_conf] == "yes" ) { document.getElementById("id_act_debug").checked = true } else { document.getElementById("id_act_debug").checked = false };
	document.getElementById("id_act_no_certtype").checked = ( local_no_certtype[act_conf] == "yes" ) ? "checked" : ""
//	document.getElementById("id_act_tap2lan").checked = ( local_tap2lan[act_conf] == "yes" ) ? "checked" : ""
	if ( local_client_info[act_conf] == "yes" ) { document.getElementById("id_act_client_info").checked = true } else { document.getElementById("id_act_client_info").checked = false };

	if ( local_own_keys[act_conf] != "" ) {
		document.getElementById("id_act_own_keys").checked = true
		if ( local_own_keys[act_conf] == "hidden" ) {
			document.getElementById("id_act_hide_keys").checked = true
		}
		else {
			document.getElementById("id_act_hide_keys").checked = false
		}
	}
	else {
		document.getElementById("id_act_own_keys").checked = false
	}

	if ( local_loadtun == "yes" ) {
		document.getElementById("id_is_loadtun").checked = true
	}
	else {
		document.getElementById("id_is_loadtun").checked = false
	}

	if ( local_expert == "yes" ) {
		document.getElementById("id_is_expert").checked = true
	}
	else {
		document.getElementById("id_is_expert").checked = false
	}

	document.getElementById("id_act_cipher").value = local_cipher[act_conf];
	if (document.getElementById("id_act_cipher").value != local_cipher[act_conf]) {
		alert_cipher=local_cipher[act_conf];
	}

	document.getElementById("id_act_verbose").value=local_verbose[act_conf];
	//document.getElementById("id_act_debug_time").value=local_debug_time[act_conf];
	document.getElementById("id_act_local").value=local_local[act_conf];
	document.getElementById("id_act_remote").value=local_remote[act_conf];
	document.getElementById("id_act_port").value=local_port[act_conf];
	document.getElementById("id_act_box_ip").value=local_box_ip[act_conf];
	document.getElementById("id_act_box_mask").value=local_box_mask[act_conf];
	document.getElementById("id_act_tap2lan").value=local_tap2lan[act_conf];
	document.getElementById("id_act_remote_ip").value=local_remote_ip[act_conf];
	document.getElementById("id_act_dhcp_range").value=local_dhcp_range[act_conf];
	document.getElementById("id_act_local_net").value=local_local_net[act_conf];
	document.getElementById("id_act_remote_net").value=local_remote_net[act_conf];
	document.getElementById("id_act_mtu").value=local_mtu[act_conf];
	document.getElementById("id_act_keepalive_ping").value=local_keepalive_ping[act_conf];
	document.getElementById("id_act_keepalive_timeout").value=local_keepalive_timeout[act_conf];
	document.getElementById("id_act_maxclients").value=local_maxclients[act_conf];
	document.getElementById("id_act_push_domain").value=local_push_domain[act_conf];
	document.getElementById("id_act_push_dns").value=local_push_dns[act_conf];
	document.getElementById("id_act_push_wins").value=local_push_wins[act_conf];
	document.getElementById("id_act_shaper").value=local_shaper[act_conf];
	document.getElementById("id_act_client_info").value=local_client_info[act_conf];
	document.getElementById("id_act_additional").value=local_additional[act_conf];
	document.getElementById("id_act_udp_fragment").value=local_udp_fragment[act_conf];
	document.getElementById("id_act_files2cp").value=local_files2cp[act_conf];
if (alert_lzo || alert_cipher) {
	tmp=ALERT_START;
	if (alert_lzo) tmp+=' - LZO'+ALERT_UNSUPPORTED ;
	if (alert_cipher) tmp+=' - cipher '+alert_cipher+ALERT_UNSUPPORTED ;
	tmp += ALERT_END;
	alert ( tmp );
  }

}

function init_configs() {
	while (document.getElementById("id_act_config").length < local_config_count) {
		Neu = new Option(local_config_names[1+document.getElementById("id_act_config").length]);
		document.getElementById("id_act_config").options[document.getElementById("id_act_config").length] = Neu;
		Neu.value = document.getElementById("id_act_config").length;
	}
}

function add_config() {
	value=local_config_count + 1;
	tmpname=document.getElementById("id_act_config_name").value.replace(/\s/g, "_") || "Config"+value;
	x=1;
	usednames=local_config_names.join("#");
	usednames=usednames+"#";
	tmp='usednames.search(/#'+tmpname+'#/)';
	found=eval(tmp);
	while ( found != -1  ) {
		tmpname="Config"+ (value+x);
		x+=1;
		tmp='usednames.search(/#'+tmpname+'#/)';
		found=eval(tmp);
	}
	Neu = new Option(tmpname);
	document.getElementById("id_act_config").options[document.getElementById("id_act_config").length] = Neu;
	Neu.value = value;
	Neu.selected="selected";
	local_config_count = value;
	for (v=0; v<variablen.length; v++) {
		tmp="local_"+variablen[v].toLowerCase()+'['+value+']=local_'+variablen[v].toLowerCase()+'[0]'
		eval(tmp);
	}
	local_config_names[value]=tmpname;
	local_port[value]= 1193 + value + x;
	changeconf();
}

function del_config() {
	if (local_config_count >1) {
		selindex=document.getElementById("id_act_config").selectedIndex;
		if ( selindex > 0) {
			for (v=0; v<variablen.length; v++) {
				tmp='local_'+variablen[v].toLowerCase()+'.splice(selindex+1 , 1)'
				eval(tmp);
				if (selindex < backup_config_count ) {
					tmp='backup_'+variablen[v].toLowerCase()+'.splice(selindex+1 , 1)'
					eval(tmp);
				}
			}
			document.getElementById("id_act_config").options[selindex] = null;
			local_config_count = local_config_count - 1;
			if (selindex < backup_config_count ) { backup_config_count-- };
			document.getElementById("id_act_config").selectedIndex=0;
			changeconf();
		}
		else {
			alert($(lang de:"\"Die 'default' Konfiguration kann nicht entfernt werden\"" en:"\"The default configuration cannot be removed.\""));
		}
	}
}

function Update_Client_Values() {
	var j=0;
	var myip="";
	var myname="";
	var mynet="";
	var tmp="";
	var number=Number(local_clients_defined[act_conf]);
	for (j=0;j<number;j++) {
		tmp='cl_ip[' + j + ']';
		myip=myip+document.getElementById( tmp ).value+":";
		tmp='cl_name[' + j + ']';
		myname=myname+document.getElementById( tmp ).value+":";
		tmp='cl_net[' + j + ']';
		mynet=mynet+document.getElementById( tmp ).value+":";
	}

	local_client_ips[act_conf]=myip;
	local_client_names[act_conf]=myname;
	local_client_nets[act_conf]=mynet;

	Consolidate_Vars();
}

function addRowToTable(name) {
	var tbl = document.getElementById(name);
	var lastRow = tbl.rows.length;
	var j = lastRow;
	local_clients_defined[act_conf] = Number(local_clients_defined[act_conf])+1;
	var row = tbl.insertRow(lastRow);

	var myip=local_client_ips[act_conf].split(":");
	var myname=local_client_names[act_conf].split(":");
	var mymask=local_client_masks[act_conf].split(":");
	var mynet=local_client_nets[act_conf].split(":");

	var cell = row.insertCell( 0 );
	input = document.createElement( 'input' );
	input.type = 'text';
	input.id = 'cl_name[' +(j-1)+ ']';
	if (!myname[(j-1)]) {myname[(j-1)]="client_" + (j-1) };
	input.value = myname[(j-1)];
	input.onblur = Update_Client_Values;
	input.size = 17;
	input.title=$(lang de:"\"Name des Clients wie im Zertifikat\"" en:"\"Client name used in certificate\"");
	cell.appendChild( input );

	cell = row.insertCell( 1 );
	var input = document.createElement( 'input' );
	input.type = 'text';
	input.id = 'cl_ip[' + (j-1) + ']';
	input.size = 12;
	input.align="left";
	if (!myip[(j-1)]) {myip[(j-1)]="-"};
	input.value = myip[(j-1)];
	input.onblur = Update_Client_Values;
	input.title="$(lang de:"VPN-IP des Clients (im gleichen Netz wie die &quot;Lokale IP&quot; oben)" en:"Client VPN-IP (in the same network as &quot;local IP&quot; above)")";
	cell.appendChild( input );

	cell = row.insertCell( 2 );
	input = document.createElement( 'input' );
	input.type = 'text';
	input.id = 'cl_net[' +(j-1)+ ']';
	input.size = 40;
	if (!mynet[(j-1)]) {mynet[(j-1)]="-"};
	input.value = mynet[(j-1)];
	input.onblur = Update_Client_Values;
	input.title="$(lang de:"Dieses IP-Netz wird zum Client geroutet." en:"This network will be routed to the client")";
	cell.appendChild( input );

	if (local_clients_defined[act_conf] == 1) {changeval(); }
}

function removeRowFromTable(name) {
	var tbl = document.getElementById(name);
	var lastRow = tbl.rows.length;
	if (lastRow >= 2) {
		tbl.deleteRow(lastRow - 1);
		local_clients_defined[act_conf] = Number(local_clients_defined[act_conf]) -1;
	}
	if (local_clients_defined[act_conf] == 0) { changeval(); }
}

function changeval(value) {
	if(!document.getElementsByTagName) { return; }

	local_cipher[act_conf]= document.getElementById("id_act_cipher").value;

	document.getElementById("div_add_tap").style.display = (document.getElementById("id_act_tap").checked)? "block" : "none";

	if ( act_conf > 1 && document.getElementById("id_act_config").value != 1 ) {
		document.getElementById("div_own_keys").style.display = "block";
		if ( local_own_keys[act_conf] != "" ) {
			document.getElementById("div_hide_keys").style.display = "block";
		}
		else {
			document.getElementById("div_hide_keys").style.display = "none";
			document.getElementById("id_act_hide_keys").checked = false;
		}
	}
	else {
		document.getElementById("div_own_keys").style.display = "none";
		document.getElementById("div_hide_keys").style.display = "none";
	}

	if ( local_expert == "yes" ) {
		document.getElementById("sec-conf").style.display = ("$OPENVPN_ENABLED"=="inetd")? "none":"block";
		document.getElementById("div_expert").style.display = "block";
	}
	else {
		document.getElementById("sec-conf").style.display = "none";
		document.getElementById("div_expert").style.display = "none";
	}

	if ( document.getElementById("id_act_static").checked ) {
		document.getElementById("div_tls").style.display = "none";
		document.getElementById("div_no_certtype").style.display = "none";
		document.getElementById("div_client_pull").style.display = "none";
		document.getElementById("id_act_pull").checked = false;
	}
	else {
		document.getElementById("div_tls").style.display = "inline";
		document.getElementById("div_client_pull").style.display = "block";
		document.getElementById("div_no_certtype").style.display = ( document.getElementById("id_act_server").checked )? "none": "block";
	}

	if ( document.getElementById("id_act_debug").checked ) {
		document.getElementById("div_debug").style.display = "block";
	}
	else {
		document.getElementById("div_debug").style.display = "none";
		local_verbose[act_conf]=3;
	}

	//server configuration
	if ( document.getElementById("id_act_server").checked ) {
		document.getElementById("sec-server-conf").style.display = "block";
		document.getElementById("div_redirect").style.display = "none";
		document.getElementById("div_dhcp").style.display = "block";
		document.getElementById("div_configure_ip").style.display = "block";
		document.getElementById("div_port").style.display = "inline";
		document.getElementById("div_config_server_off_ip").style.display = "none";
		document.getElementById("div_client_pull").style.display = "none";
		if ( document.getElementById("id_act_client_info").checked ) {
			document.getElementById("div_client_table").style.display = "block";
			document.getElementById("div_set_remote_net").style.display = "none";
			local_remote_net[act_conf]="";
		}
		else {
			document.getElementById("div_client_table").style.display = "none";
			document.getElementById("div_set_remote_net").style.display = "block";
		}

		if ( document.getElementById("id_act_static").checked) {
			document.getElementById("sec-server-conf").style.display = "none";
			document.getElementById("div_allow_clientinfos").style.display = "none";
			document.getElementById("div_push_local_net").style.display = "none";
			document.getElementById("div_dhcp").style.display = "none";
			local_dhcp_range[act_conf]=""; document.getElementById("id_act_dhcp_range").value ="";
			local_client2client[act_conf]=""; document.getElementById("id_act_c2c").checked = "";
		}
		else {
			document.getElementById("sec-server-conf").style.display = "block";
			document.getElementById("div_allow_clientinfos").style.display = "block";
			document.getElementById("div_dhcp").style.display = "block";
			document.getElementById("div_push_local_net").style.display = "block";
		}

		if ( document.getElementById("id_act_tap").checked ) {
			document.getElementById("id_act_box_ip").value = ( document.getElementById("id_act_tap2lan").value == "uselanip" ) ? "-- (LAN IP)": local_box_ip[act_conf];
			document.getElementById("div_ip_and_net").style.display = ( document.getElementById("id_act_tap2lan").value == "uselanip" ) ? "none": "block";
			document.getElementById("div_ip_loc_rem").style.display = "none";
		}
		else {
			if ( document.getElementById("id_act_static").checked) {
				document.getElementById("div_ip_and_net").style.display = "none";
				document.getElementById("div_ip_loc_rem").style.display = "block";
			}
			else {
				var maxcli = document.getElementById("id_act_maxclients").value;
				if (maxcli == 1 || maxcli >1 && local_clients_defined[act_conf] == 0 ) {
					document.getElementById("div_ip_and_net").style.display = "none";
					document.getElementById("div_ip_loc_rem").style.display = "block";
					document.getElementById("div_set_remote_net").style.display = "block";
				}
				else {
					document.getElementById("div_ip_and_net").style.display = "block";
					document.getElementById("div_ip_loc_rem").style.display = "none";
					document.getElementById("div_set_remote_net").style.display = "none";
					local_remote_net[act_conf]="";
				}
			}
		}
	}
	//client configuration
	else {
		document.getElementById("sec-server-conf").style.display = "none";
		document.getElementById("div_dhcp").style.display = "none";
		document.getElementById("div_port").style.display = "none";
		document.getElementById("div_redirect").style.display = "block";
		document.getElementById("div_push_local_net").style.display = "none";
		document.getElementById("div_set_remote_net").style.display = "block";
		document.getElementById("div_config_server_off_ip").style.display = "block";
		if (document.getElementById("id_act_pull").checked) {
			document.getElementById("div_dhcp_client").style.display = "block";
		}
		else {
			document.getElementById("div_dhcp_client").style.display = "none";
			document.getElementById("id_act_dhcp_client").checked = false;
		}
		if (document.getElementById("id_act_dhcp_client").checked) {
			document.getElementById("div_configure_ip").style.display = "none";
		}
		else {
			document.getElementById("div_configure_ip").style.display = "block";
		}
		if (document.getElementById("id_act_tap").checked) {
			document.getElementById("div_ip_and_net").style.display = "block";
			document.getElementById("div_ip_loc_rem").style.display = "none";
		}
		else {
			document.getElementById("div_ip_and_net").style.display = "none";
			document.getElementById("div_ip_loc_rem").style.display = "block";
		}
	}
	Consolidate_Vars();
}

Init_Vars();
Init_Table('tunclients_table');
init_configs();
Init_Checkbox();
changeval();
</script>
EOF

sec_end

