#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Konfigurationsverwaltung" en:"Multiple Configurations")'

cat << EOF
<select id="id_act_config" name="my_config" size="1" style="width: 120px"  onchange="changeconf()"><option value="1">default</option></select>
<input type="button" value=" - " title=$(lang de:"\'diese Konfiguration l&ouml;schen (nicht default)\'" en:"\'delete this Configuration (not default)\'") onclick='if (local_config_count > 1) del_config(); else alert("Das ist schon die letze Konfig!");' />
<input type="button" value=" + " title=$(lang de:"\'eine Konfiguration hinzuf&uuml;gen\'" en:"\'add a configuration\'" ) onclick="add_config();" />
<input type="text" size="12" maxlength="12" title=$(lang de:"\'Eine kurze Bezeichnung f&uuml;r die neue Konfig (z.B. \"Buero\" oder \"zu_Franz\")\'" en:"\'Short description e.g. \"office\" or \"notebook\"\'")  
id="id_act_config_name"> $(lang de:"neuer Konfigname (optional)" en:"Config name (optional)")
EOF
sec_end

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<input type="hidden" id="id_enabled"   name="enabled" value="$OPENVPN_ENABLED">
<input type="hidden" id="id_autostart"   name="autostart" value="$OPENVPN_AUTOSTART">
<input type="hidden" id="id_debug"   name="debug" value="$OPENVPN_DEBUG">
<input type="hidden" id="id_debug_time"   name="debug_time" value="$OPENVPN_DEBUG_TIME">
<input type="hidden" id="id_local"   name="local" value="$OPENVPN_LOCAL">
<input type="hidden" id="id_mode"   name="mode" value="$OPENVPN_MODE">
<input type="hidden" id="id_remote"   name="remote" value="$OPENVPN_REMOTE">
<input type="hidden" id="id_port"   name="port" value="$OPENVPN_PORT">
<input type="hidden" id="id_proto"   name="proto" value="$OPENVPN_PROTO">
<input type="hidden" id="id_type"   name="type" value="$OPENVPN_TYPE">
<input type="hidden" id="id_box_ip"   name="box_ip" value="$OPENVPN_BOX_IP">
<input type="hidden" id="id_box_mask"   name="box_mask" value="$OPENVPN_BOX_MASK">
<input type="hidden" id="id_remote_ip"   name="remote_ip" value="$OPENVPN_REMOTE_IP">
<input type="hidden" id="id_dhcp_range"   name="dhcp_range" value="$OPENVPN_DHCP_RANGE">
<input type="hidden" id="id_local_net"   name="local_net" value="$OPENVPN_LOCAL_NET">
<input type="hidden" id="id_remote_net"   name="remote_net" value="$OPENVPN_REMOTE_NET">
<input type="hidden" id="id_dhcp_client"   name="dhcp_client" value="$OPENVPN_DHCP_CLIENT">
<input type="hidden" id="id_mtu"   name="mtu" value="$OPENVPN_MTU">
<input type="hidden" id="id_auth_type"   name="auth_type" value="$OPENVPN_AUTH_TYPE">
<input type="hidden" id="id_cipher"   name="cipher" value="$OPENVPN_CIPHER">
<input type="hidden" id="id_tls_auth"   name="tls_auth" value="$OPENVPN_TLS_AUTH">
<input type="hidden" id="id_float"   name="float" value="$OPENVPN_FLOAT">
<input type="hidden" id="id_keepalive"   name="keepalive" value="$OPENVPN_KEEPALIVE">
<input type="hidden" id="id_keepalive_ping"   name="keepalive_ping" value="$OPENVPN_KEEPALIVE_PING">
<input type="hidden" id="id_keepalive_timeout"   name="keepalive_timeout" value="$OPENVPN_KEEPALIVE_TIMEOUT">
<input type="hidden" id="id_complzo"   name="complzo" value="$OPENVPN_COMPLZO">
<input type="hidden" id="id_maxclients"   name="maxclients" value="$OPENVPN_MAXCLIENTS">
<input type="hidden" id="id_client2client"   name="client2client" value="$OPENVPN_CLIENT2CLIENT">
<input type="hidden" id="id_push_dns"   name="push_dns" value="$OPENVPN_PUSH_DNS">
<input type="hidden" id="id_push_wins"   name="push_wins" value="$OPENVPN_PUSH_WINS">
<input type="hidden" id="id_redirect"   name="redirect" value="$OPENVPN_REDIRECT">
<input type="hidden" id="id_verbose"   name="verbose" value="$OPENVPN_VERBOSE">
<input type="hidden" id="id_shaper"   name="shaper" value="$OPENVPN_SHAPER">
<input type="hidden" id="id_udp_fragment"   name="udp_fragment" value="$OPENVPN_UDP_FRAGMENT">
<input type="hidden" id="id_pull"   name="pull" value="$OPENVPN_PULL">
<input type="hidden" id="id_logfile"   name="logfile" value="$OPENVPN_LOGFILE">
<input type="hidden" id="id_mgmnt"   name="mgmnt" value="$OPENVPN_MGMNT">
<input type="hidden" id="id_clients_defined"   name="clients_defined" value="$OPENVPN_CLIENTS_DEFINED">
<input type="hidden" id="id_client_info"   name="client_info" value="$OPENVPN_CLIENT_INFO">
<input type="hidden" id="id_client_ips"   name="client_ips" value="$OPENVPN_CLIENT_IPS">
<input type="hidden" id="id_client_names"   name="client_names" value="$OPENVPN_CLIENT_NAMES">
<input type="hidden" id="id_client_nets"   name="client_nets" value="$OPENVPN_CLIENT_NETS">
<input type="hidden" id="id_client_masks"   name="client_masks" value="$OPENVPN_CLIENT_MASKS">
<input type="hidden" id="id_config_names"   name="config_names" value="$OPENVPN_CONFIG_NAMES">
<input type="hidden" id="id_config_count"   name="config_count" value="$OPENVPN_CONFIG_COUNT">
<input type="hidden" id="id_config_changed"   name="config_changed" value="$OPENVPN_CONFIG_CHANGED">
<input type="hidden" id="id_additional"   name="additional" value="$OPENVPN_ADDITIONAL">
<input type="hidden" id="id_own_keys"   name="own_keys" value="$OPENVPN_OWN_KEYS">
<input type="hidden" id="id_expert"   name="expert" value="$OPENVPN_EXPERT">
<input type="hidden" id="id_no_certtype"   name="no_certtype" value="$OPENVPN_NO_CERTTYPE">
<input type="hidden" id="id_param_1"   name="param_1" value="$OPENVPN_PARAM_1">
<input type="hidden" id="id_param_2"   name="param_2" value="$OPENVPN_PARAM_2">
<input type="hidden" id="id_param_3"   name="param_2" value="$OPENVPN_PARAM_3">


<p><b>$(lang de:"Starttyp" en:"Start type"): &nbsp; &nbsp;</b><input id="id_act_start_auto" type="radio" name="my_enabled"  onclick='(local_autostart[act_conf]="yes"); changeval()'><label for="start_auto"> $(lang de:"Automatisch" en:"Automatic")</label> 
<input id="id_act_start_man" type="radio" name="my_enabled" onclick='(local_autostart[act_conf]=""); changeval()'><label for="start_man"> $(lang de:"Manuell" en:"Manual")</label>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <input  id="id_act_debug" type="checkbox" onclick='if (this.checked) (local_debug[act_conf]="yes"); else (local_debug[act_conf]=""); changeval()' ><label for="debug"> Debug-Mode</label> <br />
<small style="font-size:0.8em">Debug-Mode: $(lang de:"Alle Ausgaben protokollieren nach " en:"Save messages to ") "/var/tmp/debug_openvpn.out" </small> <br /> 
<div id="div_debug">
 $(lang de:"\"Ausf&uuml;rlichkeit\" des Logs" en:"Verbosity") (Verb-Level) <input id="id_act_verbose" type="text" title=$(lang de:"\'\"Geschw&auml;tzigkeit\": Normal=3,  \"R\"/\"W\" pro Paket=5,  Ausf&uuml;hrlich=6,  \"alles\"=11\'" en:"\'Verbosity: normal=3,  \"R\"/\"W\ per paket=5, detailed=6, \"everything\"=11\'") size="1" maxlength="1"  onblur='(local_verbose[act_conf]=this.value); Consolidate_Vars();' >
 <br />
 <small style="font-size:0.8em">$(lang de:"<b>!Stoppen des Dienstes nach einiger Zeit nicht vergessen!</b>, sonst l&auml;uft das Filesystem voll!" en:"<b>!Don\'t forget to stop deamon after some time to prevent filesystem overflow!</b>") <br />
$(lang de:"Die Log-Datei wird beim n&auml;chsten Start ohne Debug-Mode gel&ouml;scht." en:"Log file will be deleted next start w/o debug mode")  </small> <br /> 
</div>
EOF
sec_end

sec_begin '$(lang de:"Einstellungen" en:"Configuration")'

cat << EOF
<p>$(lang de:"Modus" en:"Mode"): <input id="id_act_server" type="radio" name="my_mode" onclick='(local_mode[act_conf]="server"); changeval()'; ><label for="id_server"> Server</label>
&nbsp;<input id="id_act_client" type="radio" name="my_mode" onclick='(local_mode[act_conf]="client"); changeval()'; ><label for="id_client"> Client</label>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <input id="id_act_tap" type="radio" name="my_type" value="tap" onclick='(local_type[act_conf]="tap"); changeval()'; ><label for="id_tap"> $(lang de:"Br&uuml;cke" en:"Bridge") (TAP)</label>&nbsp;
<input id="id_act_tun" type="radio" name="my_type" value="tun" onclick='(local_type[act_conf]="tun"); changeval()' ><label for="id_tun"> Tunnel (TUN)</label></p>
<p style="display:inline" >$(lang de:"Protokoll" en:"Protocol"): <input id="id_act_udp" type="radio" name="my_proto" value="udp" onclick='(local_proto[act_conf]="udp"); Consolidate_Vars()'><label for="id_udp"> UDP</label>
&nbsp;<input id="id_act_tcp" type="radio" name="my_proto" value="tcp" onclick='(local_proto[act_conf]="tcp"); Consolidate_Vars()'> <label for="id_tcp"> TCP</label>
 &nbsp; &nbsp; <div id="div_port" style="display:inline"> Server Port: <input id="id_act_port" type="text" 
 title=$(lang de:"\'Port, auf dem der Server auf Verbindungsw&uuml;nsche \"lauscht\"\'" en:"\"Server is listening for incoming requests on this port\"")size="4" maxlength="5" 
 onblur='(local_port[act_conf]=this.value); Consolidate_Vars() ' > </div> 
  </p>
<div id="div_config_server_off_ip">
<p>Server $(lang de:"und ggf. Port" en:"(and port if needed)"): <input id="id_act_remote" type="text" size="40" value="" onblur='(local_remote[act_conf]=this.value); Consolidate_Vars() '>
<br />
<small style="font-size:0.8em"> $(lang de:"Server (und  Port, falls Port &ne; 1194) z.B. \"10.1.2.3\" oder \"ich.dyndns.org 4711\"" en:"Server (and port if port &ne; 1194) e.g. \"10.1.2.3\" or \"me.dyndns.org 123\"") </small>
</p>
</div>
EOF

sec_end
sec_begin '$(lang de:"Sicherheit" en:"Security")'

cat << EOF
<p>$(lang de:"Authentifizierungsmethode" en:"Authentification Type"): <input id="id_act_static" type="radio" name="my_auth_type" onclick='(local_auth_type[act_conf]="static"); changeval()'; ><label for="id_static"> $(lang de:"statischer Schl&uuml;ssel" en:"static key")</label>
&nbsp;<input id="id_act_certs" type="radio" name="my_auth_type" onclick='(local_auth_type[act_conf]="certs"); changeval()';><label for="id_certs"> $(lang de:"Zertifikate" en:"Certificates")</label></p>
Cipher: <select id="id_act_cipher" name="my_cipher" onchange="changeval()"><option value="BF-CBC">Blowfish</option><option value="AES-128-CBC">AES 128</option>
<option value="AES-256-CBC">AES 256</option><option value="DES-EDE3-CBC">Triple-DES</option></select>
<div id="div_tls"  style="display:inline">   &nbsp; &nbsp; &nbsp; &nbsp; $(lang de:"bei Zertifikaten" en:"with certificates"): 
<input id="id_act_tls_auth" type="checkbox" name="my_tls_auth" onclick='if (this.checked) (local_tls_auth[act_conf]="yes"); else (local_tls_auth[act_conf]=""); changeval()'>
<label for="id_act_tls_auth">TLS-$(lang de:"Authentifizierung" en:"Authentication") </label>
</div>
<br />
<small style="font-size:0.8em">$(lang de:"Muss auf Server <b>und</b> Client identisch sein" en:"Must be equal on server <b>and</b> client")</small>
<div id="div_no_certtype" style="display:none">&nbsp; &nbsp; $(lang de:"Keine Pr&uuml;fung vom " en:"Accept server cert w/o ") "ns-cert-type"
<input id="id_act_no_certtype" type="checkbox" name="my_no_certtype" title=$(lang de:"\'Auch Zertifikate ohne \"ns-cert-type server\" akzeptieren'" en:"\'Accept server certs even without \"ns-cert-type server\"'") onclick='if (this.checked) (local_no_certtype[act_conf]="yes"); else (local_no_certtype[act_conf]=""); changeval()'> 
</div>

<p>
<div id="div_own_keys"  style="display:inline"> 
<input id="id_act_own_keys" type="checkbox" name="my_own_keys"
title=$(lang de:"\'Diese Konfiguration ben&ouml;tigt eigene Keys/Zertifikate. Bei \"Einstellungen\" eintragen.\'" en:"\'This configuration requires its own key/certs. Insert in menu \"configuration\".\'")
 onclick='if (this.checked) (local_own_keys[act_conf]="yes"); else (local_own_keys[act_conf]=""); changeval()'>
<label for="id_act_own_keys">$(lang de:"Eigene Keys/Certs f&uuml;r diese Config" en:"Own key/certs for this config")</label>
<div id="div_hide_keys" style="display:inline">   &nbsp; &nbsp; <input id="id_act_hide_keys" type="checkbox" title=$(lang de:"\'Keys/Zertifikate unter \"Einstellungen\" nicht anzeigen (zur &Uuml;bersichtlichkeit).\'" en:"\'Hide Keys/Certs in menu \"Configuration\" (for clarity)\'")
name="my_hide_keys" onclick='if (this.checked) (local_own_keys[act_conf]="hidden"); else (local_own_keys[act_conf]="yes"); changeval()'>
<label for="id_act_hide_keys">$(lang de:"Key-Einstellung ausblenden" en:"Hide Keys") </label>
</div>
</div>
</p>
EOF

sec_end
sec_begin '$(lang de:"VPN IP-Adressen und Routing im VPN" en:"VPN IP-Addresses and VPN Routing")'

cat << EOF
<small style="font-size:0.8em"> <i>$(lang de:"Hier werden die IP-Adressen und das Routing vom VPN konfiguriert." en:"You configure VPN IP addresses and routing inside the VPN here")</i></small>
<p><div id="div_configure_ip">
$(lang de:"Lokale IP" en:"local IP"): <input id="id_act_box_ip" size="16" title=$(lang de:"\'IP des lokelen VPN Interfaces ( tun / tun ). Z.B. \"192.168.1.1\" \'" en:"\'IP of local VPN interface (tap / tun ) e.g.\"192.168.1.1\" \'")
maxlength="16" type="text"  onblur='(local_box_ip[act_conf]=this.value); Consolidate_Vars();' >
<div id="div_ip_and_net"> &nbsp; &nbsp; $(lang de:"Netzmaske" en:"netmask"): <input id="id_act_box_mask"  
title=$(lang de:"\'Netzmaske f&uuml;r das lokele VPN Interface ( tun / tun ). Z.B. \"255.255.255.0\" \'" en:"\'netmask for local VPN interface (tap / tun ) e.g. \"255.255.255.0\" \'") size="14" maxlength="16" type="text" 
value="" onblur='(local_box_mask[act_conf]=this.value); Consolidate_Vars();'>
</div>

<div id="div_ip_loc_rem">
&nbsp; &nbsp; Remote IP: <input id="id_act_remote_ip"  title=$(lang de:"\'IP des entfernten VPN Interfaces ( tun / tun ). Z.B. \"192.168.1.2\" \'" en:"\'IP of remote VPN interface e.g. \"192.168.1.2\"\' ") size="16" 
maxlength="16" type="text" value="" onblur='(local_remote_ip[act_conf]=this.value); Consolidate_Vars();'>
</div>
</div>
<div id="div_dhcp">
<p>DHCP-Range $(lang de:"f&uuml;r" en:"for") Clients <small style="font-size:0.8em">( &lt;start-ip&gt; &lt;end-ip&gt; )</small>  &nbsp;   <input id="id_act_dhcp_range" 
title=$(lang de:"\' Bereich f&uuml;r Client-IPs. Syntax: &lt;start-ip&gt; &lt;end-ip&gt;, z.B. \"192.168.1.10 192.168.1.20\"\'" en:"\' Range for Client-IPs. Syntax: &lt;start-ip&gt; &lt;end-ip&gt;, e.g. \"192.168.1.10 192.168.1.20\"\'") 
type="text" size="30" maxlength="33" value="" onblur='(local_dhcp_range[act_conf]=this.value); Consolidate_Vars();'></p>
</div>

<p> <b> Optional: Routing $(lang de:"von IP-Netzen" en:"of IP networks")</b></p>
<div id="div_set_remote_net">
<p>$(lang de:"Entferntes Netz" en:"remote net"): <input id="id_act_remote_net" size="50" type="text"onblur='(local_remote_net[act_conf]=this.value); Consolidate_Vars();' >

<br />
<small style="font-size:0.8em">$(lang de:"Netz wird &uuml;ber VPN geroutet." en:"Net routed through VPN.")  &nbsp;  &nbsp; Syntax: <i>TUN:</i> &lt;ip&gt; &lt;mask&gt;  &nbsp;  <i>TAP:</i> &lt;ip&gt; &lt;mask&gt; &lt;gateway&gt;</small></p>

</div>
<div id="div_redirect">
<input id="id_act_redirect" type="checkbox" 
    title=$(lang de:"\'Client-Internetzugriff &uuml;ber den VPN-Server umgeleiten\'" en:"\'Redirect client traffic through VPN\'") 
    onclick='if (this.checked) (local_redirect[act_conf]="yes"); else (local_redirect[act_conf]=""); changeval()' > 
    <label for="id_redirect">$(lang de:"Clientverkehr umleiten" en:"Redirect client traffic") </label>
</div>
</p>
<div id="div_push_local_net">
<p>$(lang de:"Lokales Netz" en:"Local network"): <input id="id_act_local_net" title=$(lang de:"\'lokales Netz, Syntax: &lt;ip&gt; &lt;subnetmask&gt; z.B. \"192.168.178.0 255.255.255.0\"\'"
en:"\'local net, syntax: &lt;ip&gt; &lt;subnetmask&gt; z.B. \"192.168.178.0 255.255.255.0\"\'")
size="40" type="text" onblur='(local_local_net[act_conf]=this.value); Consolidate_Vars();' ><br />
<small style="font-size:0.8em">$(lang de:"Der Client erh&auml;lt eine Route zu diesem Netz per" en:"Client will receive a network route via") "push".  Syntax: &lt;ip&gt; &lt;mask&gt;</small></p>
<div id="div_allow_clientinfos">
<p><input id="id_act_client_info" type="checkbox" name="my_client_info" value="yes" onclick='if (this.checked) (local_client_info[act_conf]="yes"); else (local_client_info[act_conf]=""); changeval()'>
<label for="id_client_info">$(lang de:"Erweiterte Clientkonfiguration" en:"Extended client configuration") <br /><small style="font-size:0.8em">$(lang de:"Clients feste VPN-IPs zuordnen und Netze zu bestimmten Clients routen" en:"Static VPN-IPs for client and routing nets to clients")</small></label> </p>
<div id="div_client_table">
<table id="tunclients_table">

<input type="button" value=$(lang de:"\"Client hinzuf&uuml;gen\"" en:"\"Add Client\"") onclick="addRowToTable('tunclients_table');" />
<input type="button" value=$(lang de:"\"Client entfernen\"" en:"\"Remove client\"") onclick="removeRowFromTable('tunclients_table');" />
<br />

<tr id="tunclients">
&nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp;  <td>$(lang de:"Clientname" en:"Client name") <small style="font-size:0.8em"> ($(lang de:"Zertifikat" en:"from cert"))</small></td> <td>Client-VPN-IP </td>&nbsp;    
&nbsp;   <td>$(lang de:"Netz b. Client" en:"Client net")<small style="font-size:0.8em">&nbsp; &nbsp; (Syntax: &lt;ip&gt; &lt;subnetmask&gt;)</small></td>
</tr>

</table>
<p><b>$(lang de:"Bitte beim Client \"pull\" aktivieren" en:"Activate \"pull\" in client config")</b> (<i>$(lang de:"Optionen vom Server empfangen" en:"Receive options from server")</i>)</p>
</div>
</div>
</div>
<div id="div_client_pull">
<p><input id="id_act_pull" type="checkbox" name="my_pull" title=$(lang de:"\'Client empf&auml;ngt Optionen (z.B. Routen), die der Server schickt\'" en:"\'Client receives options (e.g. routes) the server is pusching\'") 
    onclick='if (this.checked) (local_pull[act_conf]="yes"); else (local_pull[act_conf]=""); changeval()' ><label for="pull">$(lang de:"Optionen vom Server empfangen (nur mit Zertifikaten)" en:"Receive options from server (only whith certs)")</label></p>
<div id="div_dhcp_client">
 &nbsp;    &nbsp; <input id="id_act_dhcp_client" type="checkbox" title=$(lang de:"\'Die \"push\"-Otionen des Servers enthalten auch die IP f&uuml;r diesen Client\'" en:"\'Server also \"push\"es the IP for this Client\'") onclick='if (this.checked) (local_dhcp_client[act_conf]="yes"); else (local_dhcp_client[act_conf]=""); changeval()'>
<label for="id_dhcp_client">$(lang de:"auch IP-Adresse vom Server empfangen" en:"receive client IP from server") <br /> <small style="font-size:0.8em">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; $(lang de:"(TAP oder vom TUN-Server mit \"erweiterter Clientkonfiguration\")" en:"(from TAP or TUN server with \"Extended client configuration\")")</small></label>
</div>
</div>

</p>
EOF

sec_end

sec_begin '$(lang de:"Server-Einstellungen (bei Zertifikaten)" en:"Server Configuration (only with certs)")'

cat << EOF
Max. Clients: <input id="id_act_maxclients" type="text" size="4" maxlength="3" 
    title=$(lang de:"\'Maximale Anzahl Clients, die sich verbinden darf\'" en:"\'Max. number of clients allowed\'") onblur="local_maxclients[act_conf]=this.value; changeval()" >
&nbsp; &nbsp;
<input id="id_act_push_redirect" type="checkbox"  
    title=$(lang de:"\'Client anweisen, Internetzugriffe &uuml;ber den VPN-Server umzuleiten\'" en:"\'Client shall redirect traffic through VPN\'")  
    onclick='if (this.checked) (local_redirect[act_conf]="yes"); else (local_redirect[act_conf]=""); changeval()' > 
    <label for="id_push_redirect">$(lang de:"Clientverkehr umleiten" en:"Redirect client traffic")</label>
&nbsp; &nbsp;
<input id="id_act_c2c" type="checkbox" 
    title=$(lang de:"\'Routing zwischen mehreren Clients einrichten; erm&ouml;glicht Zugriff zwischen Clientnetzen\'" en:"\'Enable routing between client networks\'")  
    onclick='if (this.checked) (local_client2client[act_conf]="yes"); else (local_client2client[act_conf]=""); changeval()'>
    <label for="id_c2c">Client $(lang de:"zu" en:"to") Client</label>
    
<small style="font-size:0.8em"> <br /> </small>

<table id="Push_Options">
<tr> <td><i>Push $(lang de:"Optionen" en:"Options")</i> &nbsp; &nbsp;   &nbsp; &nbsp; </td> <td>DNS Server</td> <td>WINS Server</td>&nbsp;</tr>
<tr>
<td align=center ><i> (optional)&nbsp; &nbsp;   &nbsp; &nbsp;</i></td>
<td><input id="id_act_push_dns" type="text" maxlength="16" onblur='(local_push_dns[act_conf]=this.value); Consolidate_Vars();'>  &nbsp; &nbsp;   </td>
<td><input id="id_act_push_wins" type="text" maxlength="16" onblur='(local_push_wins[act_conf]=this.value); Consolidate_Vars();'></td>
</tr>
</table>
EOF

sec_end

sec_begin '$(lang de:"Optionen" en:"Options")'
 
cat << EOF
<p><input id="id_act_keepalive" type="checkbox"  title=$(lang de:"\"Zum Aufrechterhalten der Verbindung werden Pings gesendet\"" en:"\"Send pings to keep connection\"") onclick='if (this.checked) (local_keepalive[act_conf]="yes"); else (local_keepalive[act_conf]=""); changeval()' >
<label for="id_act_keepalive"> Keepalive</label>  &nbsp; &nbsp;  
<input id="id_act_comp_lzo" type="checkbox" title=$(lang de:"\'LZO-Komprimierung nutzen? !!Muss auf Server und Client gleich sein!!\'" en:"\'use LZO compression? !!Must be used on server <b>and</b> client site!!'\'") onclick='if (this.checked) (local_complzo[act_conf]="yes"); else (local_complzo[act_conf]=""); changeval()' >
    <label for="id_comp_lzo">LZO</label>  &nbsp; &nbsp; 
<input id="id_act_float" type="checkbox" title=$(lang de:"\'Gegenseite darf w&auml;hrend &#10;der Verbindung IP &auml;ndern (z.B. bei dynamischer Adresse)\'" en:"\'Remote site may change IP during connection (e.g. dynamic IPs)\'") onclick='if (this.checked) (local_float[act_conf]="yes"); else (local_float[act_conf]=""); changeval()' >
    <label for="id_float">$(lang de:"IP-&Auml;nderung zulassen" en:"Allow IP change")</label>  &nbsp; &nbsp; 
<input id="id_act_logfile" type="checkbox" title=$(lang de:"\'Der aktuelle Status der Verbindungen wird in /var/log/openvpn.log protokolliert\'" en:"\'Actual status of connection will be logged to /var/log/openvpn.log \'") onclick='if (this.checked) (local_logfile[act_conf]="yes"); else (local_logfile[act_conf]=""); changeval()' >
    <label for="id_logfile">$(lang de:"Statusprotokoll" en:"Log status")</label></p>
<p><input id="id_is_expert" type="checkbox" title=$(lang de:"\"Selten ben&ouml;tigte Parameter und Multi-Config-F&auml;higkeit\"" en:"\"Change rarely used settings and enable multiple configs\"")  onclick='if (this.checked)  (local_expert="yes"); else (local_expert=""); changeval()' >
<label for="id_is_expert"> $(lang de:"Experteneinstellungen / Standardwerte &auml;ndern" en:"Expert settings / change standard settings") </label> <br />
<small style="font-size:0.8em">$(lang de:"Ich versichere, Parameter erst nach Lesen der Anleitung auf \"OpenVPN.net\" zu &auml;ndern ;-)" en:"I herby swear, I will not change anything without prior reading on \"OpenVPN.net\" ;-)")</small>
<div id="div_expert">
<p>$(lang de:"Bandbreitenbegrenzung [Bytes/Sek]" en:"Use shaper [bytes/sec]") (optional): <input id="id_act_shaper" type="text" 
title=$(lang de:"\"Begrenzen der Bandbreite. Erlaubte Werte zwischen 100 und 100.000.000 Bytes/Sek\"" en:"\"Bandwidth shaping. Possible values from 100 to 100.000.000 bytes/Sec\"") name="my_shaper" size="4" maxlength="5" 
onblur='if (this.value != "" && this.value <100) (this.value=100) ; if (this.value > 100000000) (this.value=100000000) ; (local_shaper[act_conf]=this.value); Consolidate_Vars();'></p>
<p>$(lang de:"Nur auf dieser Adresse arbeiten" en:"Only listen on this IP") (optional): <input id="id_act_local" type="text" size="9" value="" title=$(lang de:"\'OpenVPN nimmt nur Verbindungen auf dieser IP-Adresse an, ohne Angabe auf allen\'" en:"\'OpenVPN only listens to this IP, no entry means all IPs are accepted\'")  
maxlength="16"  onblur='(local_local[act_conf]=this.value); Consolidate_Vars()'></p>
<p>$(lang de:"Ping Abstand f&uuml;r Keepalive" en:"Seconds between keepalives"): <input id="id_act_keepalive_ping" type="text" size="3" title=$(lang de:"\"Abstand mit dem Pings gesendet werden. Standard=10 Sek.\"" en:"\"Interval for keepalive pings. Default=10 sec.\"" )  onblur='(local_keepalive_ping[act_conf]=this.value); Consolidate_Vars();'> 
 &nbsp; &nbsp; Keepalive Timeout: <input id="id_act_keepalive_timeout" type="text" size="4" title=$(lang de:"\"Nach dieser Zeit wird die Verbindung als abgebrochen betrachtet. Standard=120\"" en:"\"After this period a connection will be treated broken. Default=120\"")  onblur='(local_keepalive_timeout[act_conf]=this.value); Consolidate_Vars();'></p>
<p>MTU (optional): <input id="id_act_mtu" type="text" size="5" title=$(lang de:"\"Maximale Paketgr&ouml;&szlig;e. Normalerweise nicht zu &auml;ndern. Standard=1500\"" en:"\"Maximum paket size. Usually no need to change. Default=1500\"") onblur='(local_mtu[act_conf]=this.value); Consolidate_Vars();'>
&nbsp; &nbsp; &nbsp; &nbsp;  $(lang de:"UDP fragmentieren <small style='font-size:0.8em'>nur bei Problemen</small>" en:"Fragment UDP <small style='font-size:0.8em'>to solve UDP problems</small>"): <input id="id_act_udp_fragment" type="text" size="5" 
title=$(lang de:"\'Gr&ouml;&szlig;ere UDP-Pakete immer \"teilen\" (fragmentieren). Vorschlag=1300 (bei MTU=1500)\'" en:"\'Allways fragment UDP packets exceeding this length. Proposal=1300 (for MTU=1500)\'")  
onblur='(local_udp_fragment[act_conf]=this.value); Consolidate_Vars();'></p>
<p>$(lang de:"Zusatzparameter (ggf mit \";\" getrennt), z.B. \"par1 xy ; par2 ab ; par3\"" en:"Additional params (separated by \";\") e.g. \"par1 xy ; par2 ab ; par3\""): <input id="id_act_additional" 
type="text"size="70" onblur='(local_additional[act_conf]=this.value); Consolidate_Vars();'></p>
</div>
 
<script>
var act_conf=1;

FIELDSET_CONFIG = 0
FIELDSET_SERVER = 5
variablen=[ "AUTOSTART", "DEBUG", "DEBUG_TIME", "LOCAL", "MODE", "REMOTE", "PORT", "PROTO", "TYPE", "BOX_IP", "BOX_MASK", "REMOTE_IP", "DHCP_RANGE", "LOCAL_NET", "REMOTE_NET", "DHCP_CLIENT", "MTU", "AUTH_TYPE", "CIPHER", "TLS_AUTH", "FLOAT", "KEEPALIVE", "KEEPALIVE_PING", "KEEPALIVE_TIMEOUT", "COMPLZO", "MAXCLIENTS", "CLIENT2CLIENT", "PUSH_DNS", "PUSH_WINS", "REDIRECT", "VERBOSE", "SHAPER", "UDP_FRAGMENT", "PULL", "LOGFILE", "MGMNT", "CLIENTS_DEFINED", "CLIENT_INFO", "CLIENT_IPS", "CLIENT_NAMES", "CLIENT_NETS", "CLIENT_MASKS", "CONFIG_NAMES", "ADDITIONAL", "OWN_KEYS", "NO_CERTTYPE", "PARAM_1", "PARAM_2", "PARAM_3" ]

function Init_Vars(){
local_config_count=$OPENVPN_CONFIG_COUNT;
backup_config_count=$OPENVPN_CONFIG_COUNT;
local_expert="$OPENVPN_EXPERT";
local_config_changed=new Array();
local_config_changed[0]="new";
for (v=0; v<variablen.length; v++) {
	tmp="local_"+variablen[v].toLowerCase()+'=document.getElementById("id_'+variablen[v].toLowerCase()+'").value.split("#")'
	eval (tmp);
	tmp="backup_"+variablen[v].toLowerCase()+'=document.getElementById("id_'+variablen[v].toLowerCase()+'").value.split("#")'
	eval (tmp);
        }
}

function Consolidate_Vars(){
document.getElementById("id_config_count").value=local_config_count;
document.getElementById("id_expert").value=local_expert;
document.getElementById("id_enabled").value=local_autostart[1] ;
Find_changes();
document.getElementById("id_config_changed").value=local_config_changed.join("#"); 
for (v=0; v<variablen.length; v++) {
	tmp='document.getElementById("id_'+variablen[v].toLowerCase()+'").value=local_'+variablen[v].toLowerCase()+'.join("#")'
	eval (tmp);
        }
}

function Find_changes(){
	for (c=1; c<=local_config_count; c++) {local_config_changed[c]= (c <= backup_config_count)? "" : "new"; }
	for (v=0; v<variablen.length; v++) {
	    for (c=1; c<=backup_config_count; c++) {
		tmp="equal=(local_"+variablen[v].toLowerCase()+"["+c+"] == backup_"+variablen[v].toLowerCase()+"["+c+"] )"
		eval (tmp);
		if (!equal) {local_config_changed[c]="yes"}
		
	     }
        }
}

function changeconf(){
act_conf= 1 + document.getElementById("id_act_config").selectedIndex;
Init_Checkbox();
Init_Table('tunclients_table');
changeval();

}

function Init_Table(name){
var number=Number(local_clients_defined[act_conf]);
var tbl = document.getElementById(name);
var lastRow = tbl.rows.length;
	for(j=lastRow;j>1;j--){
	  	tbl.deleteRow(j - 1);
	}
	for(j=1;j<=number;j++){
		addRowToTable(name);
	}
local_clients_defined[act_conf]=Number(number);
}

function Init_Checkbox(){

if ( local_autostart[act_conf] == "yes" ) { document.getElementById("id_act_start_auto").checked=true  } else {document.getElementById("id_act_start_man").checked=true };
if ( local_mode[act_conf] == "server" ) { document.getElementById("id_act_server").checked=true  } else {document.getElementById("id_act_client").checked=true };
if ( local_proto[act_conf] == "tcp" ) { document.getElementById("id_act_tcp").checked=true } else {document.getElementById("id_act_udp").checked=true };
if ( local_keepalive[act_conf] == "yes" ) { document.getElementById("id_act_keepalive").checked=true } else { document.getElementById("id_act_keepalive").checked=false };
if ( local_complzo[act_conf] == "yes" ) { document.getElementById("id_act_comp_lzo").checked=true } else { document.getElementById("id_act_comp_lzo").checked=false };
if ( local_type[act_conf] == "tap" ) { document.getElementById("id_act_tap").checked=true } else {document.getElementById("id_act_tun").checked=true };
if ( local_auth_type[act_conf] == "certs" ) { document.getElementById("id_act_certs").checked=true } else {document.getElementById("id_act_static").checked=true  };
if ( local_redirect[act_conf] == "yes" ) { document.getElementById("id_act_redirect").checked=true ; document.getElementById("id_act_push_redirect").checked=true  } 
    else { document.getElementById("id_act_redirect").checked=false ; document.getElementById("id_act_push_redirect").checked=false };
if ( local_client2client[act_conf] == "yes" ) { document.getElementById("id_act_c2c").checked=true } else{ document.getElementById("id_act_c2c").checked=false };
if ( local_float[act_conf] == "yes" ) { document.getElementById("id_act_float").checked=true }else { document.getElementById("id_act_float").checked=false  } ;
if ( local_logfile[act_conf] == "yes" ) { document.getElementById("id_act_logfile").checked=true } else { document.getElementById("id_act_logfile").checked=false } ;
if ( local_dhcp_client[act_conf] == "yes" ) { document.getElementById("id_act_dhcp_client").checked=true } else { document.getElementById("id_act_dhcp_client").checked=false };
if ( local_pull[act_conf] == "yes" ) { document.getElementById("id_act_pull").checked=true }else { document.getElementById("id_act_pull").checked=false };
if ( local_tls_auth[act_conf] == "yes" ) { document.getElementById("id_act_tls_auth").checked=true } else{ document.getElementById("id_act_tls_auth").checked = false };
if ( local_debug[act_conf] == "yes" ) { document.getElementById("id_act_debug").checked=true }else { document.getElementById("id_act_debug").checked=false };
document.getElementById("id_act_no_certtype").checked= ( local_no_certtype[act_conf] == "yes" )? "checked" : ""
if ( local_client_info[act_conf] == "yes" ) { document.getElementById("id_act_client_info").checked=true }else { document.getElementById("id_act_client_info").checked=false };
if ( local_own_keys[act_conf] != "" ) { 
	document.getElementById("id_act_own_keys").checked=true
	if ( local_own_keys[act_conf] == "hidden" ) {
		document.getElementById("id_act_hide_keys").checked=true}
	else{
		document.getElementById("id_act_hide_keys").checked=false}
}
else { 
	document.getElementById("id_act_own_keys").checked=false 
};
if ( local_expert == "yes" ) { document.getElementById("id_is_expert").checked=true }else { document.getElementById("id_is_expert").checked=false };

switch (local_cipher[act_conf]) {
	case "BF-CBC":  document.getElementById("id_act_cipher").selectedIndex = 0; break;
	case "AES-128-CBC": document.getElementById("id_act_cipher").selectedIndex = 1; break;
	case "AES-256-CBC": document.getElementById("id_act_cipher").selectedIndex = 2; break;
	case "DES-EDE3-CBC": document.getElementById("id_act_cipher").selectedIndex = 3; break;
	}

document.getElementById("id_act_verbose").value=local_verbose[act_conf]  ;
//document.getElementById("id_act_debug_time").value=local_debug_time[act_conf];
document.getElementById("id_act_local").value=local_local[act_conf] ;
document.getElementById("id_act_remote").value=local_remote[act_conf] ;
document.getElementById("id_act_port").value=local_port[act_conf] ;
document.getElementById("id_act_box_ip").value=local_box_ip[act_conf] ;
document.getElementById("id_act_box_mask").value=local_box_mask[act_conf] ;
document.getElementById("id_act_remote_ip").value=local_remote_ip[act_conf] ;
document.getElementById("id_act_dhcp_range").value=local_dhcp_range[act_conf] ;
document.getElementById("id_act_local_net").value=local_local_net[act_conf] ;
document.getElementById("id_act_remote_net").value=local_remote_net[act_conf] ;
document.getElementById("id_act_mtu").value=local_mtu[act_conf] ;
document.getElementById("id_act_keepalive_ping").value=local_keepalive_ping[act_conf] ;
document.getElementById("id_act_keepalive_timeout").value=local_keepalive_timeout[act_conf] ;
document.getElementById("id_act_maxclients").value=local_maxclients[act_conf] ;
document.getElementById("id_act_push_dns").value=local_push_dns[act_conf] ; 
document.getElementById("id_act_push_wins").value=local_push_wins[act_conf] ;
document.getElementById("id_act_shaper").value=local_shaper[act_conf] ;
document.getElementById("id_act_client_info").value=local_client_info[act_conf] ;
document.getElementById("id_act_additional").value=local_additional[act_conf] ;
document.getElementById("id_act_udp_fragment").value=local_udp_fragment[act_conf] ;

}

function init_configs(){
 while (document.getElementById("id_act_config").length < local_config_count){
	 Neu = new Option(local_config_names[1+document.getElementById("id_act_config").length]);
	 document.getElementById("id_act_config").options[document.getElementById("id_act_config").length] = Neu;
 	 Neu.value = document.getElementById("id_act_config").length;
 	}
}

function add_config(){
 value=local_config_count + 1;
 tmpname=document.getElementById("id_act_config_name").value || "Config"+value ;
 x=1;
 usednames=local_config_names.join("#");
 usednames=usednames+"#";
 tmp='usednames.search(/#'+tmpname+'#/)';
 found=eval(tmp);
 while ( found != -1  ){
    tmpname="Config"+ (value+x);
    x+=1;
     tmp='usednames.search(/#'+tmpname+'#/)';
    found=eval(tmp);
 }
 Neu = new Option(tmpname.replace(/\s/g, "_"));
 document.getElementById("id_act_config").options[document.getElementById("id_act_config").length] = Neu;
 Neu.value = value;
 Neu.selected="selected";
 local_config_count = value  ;
 for (v=0; v<variablen.length; v++) {
        tmp="local_"+variablen[v].toLowerCase()+'['+value+']=local_'+variablen[v].toLowerCase()+'[0]'
        eval (tmp);
        }
 local_config_names[value]=tmpname;
 local_port[value]= 1193 + value + x;
 changeconf();

}


function del_config(){
  if (local_config_count >1){
	selindex=document.getElementById("id_act_config").selectedIndex;
	if ( selindex > 0) {
	    for (v=0; v<variablen.length; v++) {
	        tmp='local_'+variablen[v].toLowerCase()+'.splice(selindex+1 , 1)'
		eval (tmp);
		if (selindex < backup_config_count ) {
	            tmp='backup_'+variablen[v].toLowerCase()+'.splice(selindex+1 , 1)'
	            eval (tmp);                                                                                                               
	         }                                  
	    }
	 document.getElementById("id_act_config").options[selindex] = null;
	 local_config_count = local_config_count - 1;
	 if (selindex < backup_config_count ) { backup_config_count-- };
	 document.getElementById("id_act_config").selectedIndex=0;
	 changeconf();
	 }
	else{
		alert($(lang de:"\"Default-Config kann nicht gel&ouml;scht werden\"" en:"\"default config can not be removed.\""));
	 }
  }
}

function Update_Client_Values()
{	var j=0;
	var myip="";
	var myname="";
	var mynet="";
	var tmp="";
	var number=Number(local_clients_defined[act_conf]);
	for (j=0;j<number;j++){
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

function addRowToTable(name)
{
  var tbl = document.getElementById(name);
  var lastRow = tbl.rows.length;
  var j = lastRow ;
  local_clients_defined[act_conf] = Number(local_clients_defined[act_conf])+1 ;
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
	input.value = myname[(j-1)] ;
	input.onblur = Update_Client_Values;
	input.size = 17;
	input.title=$(lang de:"\"Name des Clients wie im Zertifikat\"" en:"\"Client name used in cert\"");
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
	input.title=$(lang de:"\'VPN-IP des Clients (im gleichen Netz wie die \"Lokale IP\" oben)\'" en:"\'Client VPN-IP (in the same net as \"local IP\" above)\'");
	cell.appendChild( input );

	cell = row.insertCell( 2 );
	input = document.createElement( 'input' );
	input.type = 'text';
	input.id = 'cl_net[' +(j-1)+ ']';
	input.size = 40;
	if (!mynet[(j-1)]) {mynet[(j-1)]="-"};
	input.value = mynet[(j-1)];
	input.onblur = Update_Client_Values;
	input.title=$(lang de:"\"Dieses IP-Netz wird zum Client geroutet.\"" en:"\'This net will be routed to the client\'");
	cell.appendChild( input );
	
	if (local_clients_defined[act_conf] == 1) {changeval();}
}

function removeRowFromTable(name)
{
  var tbl = document.getElementById(name);
  var lastRow = tbl.rows.length;
  if (lastRow >= 2) {
  	tbl.deleteRow(lastRow - 1);
  	local_clients_defined[act_conf] = Number(local_clients_defined[act_conf]) -1;
  }
  if (local_clients_defined[act_conf] == 0) {changeval();}
}

function changeval(value) {
  if(!document.getElementsByTagName) return;

local_cipher[act_conf]= document.getElementById("id_act_cipher").value ; 
var fieldsets = document.getElementsByTagName("fieldset");

 if ( act_conf > 1 ){
  	document.getElementById("div_own_keys").style.display = "block";
		if ( local_own_keys[act_conf] != "" ) {
			document.getElementById("div_hide_keys").style.display = "inline";}
		else{
			document.getElementById("div_hide_keys").style.display = "none";
			document.getElementById("id_act_hide_keys").checked=false;
		}
	}
  else {
  	document.getElementById("div_own_keys").style.display = "none";
  }

 if ( local_expert == "yes" ){
	fieldsets[FIELDSET_CONFIG].style.display = "block";
  	document.getElementById("div_expert").style.display = "block";
	}
  else {
  	document.getElementById("div_expert").style.display = "none";
	fieldsets[FIELDSET_CONFIG].style.display = "none";
  }

 if ( document.getElementById("id_act_static").checked ){
  	document.getElementById("div_tls").style.display = "none";
	document.getElementById("div_no_certtype").style.display = "none";
	document.getElementById("div_client_pull").style.display = "none";
	document.getElementById("id_act_pull").checked = false ;
	}
  else {
  	document.getElementById("div_tls").style.display = "inline";
	document.getElementById("div_client_pull").style.display = "block";
	document.getElementById("div_no_certtype").style.display = ( document.getElementById("id_act_server").checked )? "none": "inline";
  }
   
  if ( document.getElementById("id_act_debug").checked ){
  	document.getElementById("div_debug").style.display = "block";
	}
  else {
  	document.getElementById("div_debug").style.display = "none";
	local_verbose[act_conf]=3; 
  }
	
  if ( document.getElementById("id_act_server").checked ){
  	var fieldsets = document.getElementsByTagName("fieldset");
  	fieldsets[FIELDSET_SERVER].style.display = "block";
	document.getElementById("div_redirect").style.display = "none";
  	document.getElementById("div_dhcp").style.display = "block";
  	document.getElementById("div_port").style.display = "inline";
  	document.getElementById("div_config_server_off_ip").style.display = "none"; 
  	document.getElementById("div_client_pull").style.display = "none";
	if ( document.getElementById("id_act_client_info").checked ){
  	    document.getElementById("div_client_table").style.display = "block";
	    document.getElementById("div_set_remote_net").style.display = "none";
	    local_remote_net[act_conf]="";
	    }
	else {
  	    document.getElementById("div_client_table").style.display = "none";
	    document.getElementById("div_set_remote_net").style.display = "block";
	}
	if ( document.getElementById("id_act_static").checked){
		fieldsets[FIELDSET_SERVER].style.display = "none";
		document.getElementById("div_allow_clientinfos").style.display = "none";
		document.getElementById("div_push_local_net").style.display = "none";
		document.getElementById("div_dhcp").style.display = "none";
		local_dhcp_range[act_conf]=""; document.getElementById("id_act_dhcp_range").value ="";
		local_client2client[act_conf]=""; document.getElementById("id_act_c2c").checked = "";
	} 
    	else{
		fieldsets[FIELDSET_SERVER].style.display = "block";
		document.getElementById("div_allow_clientinfos").style.display = "block";
		document.getElementById("div_dhcp").style.display = "block";
		document.getElementById("div_push_local_net").style.display = "block";
	}	
	if ( document.getElementById("id_act_tap").checked ){
		document.getElementById("div_ip_and_net").style.display = "inline";
		document.getElementById("div_ip_loc_rem").style.display = "none";
	}	
	else {
		if ( document.getElementById("id_act_static").checked){
			document.getElementById("div_ip_and_net").style.display = "none";
			document.getElementById("div_ip_loc_rem").style.display = "inline";
		}
		else {
			var maxcli = document.getElementById("id_act_maxclients").value ;
			if (maxcli == 1 || maxcli >1 && local_clients_defined[act_conf] == 0 ){
				document.getElementById("div_ip_and_net").style.display = "none";
				document.getElementById("div_ip_loc_rem").style.display = "inline";
				document.getElementById("div_set_remote_net").style.display = "block";
			}
			else{
				document.getElementById("div_ip_and_net").style.display = "inline";
				document.getElementById("div_ip_loc_rem").style.display = "none";
				document.getElementById("div_set_remote_net").style.display = "none";
				local_remote_net[act_conf]="";
			}
		}	
	}
    } 
    else {
	fieldsets[FIELDSET_SERVER].style.display = "none";
	document.getElementById("div_dhcp").style.display = "none";
	document.getElementById("div_port").style.display = "none";
	document.getElementById("div_redirect").style.display = "inline";
	document.getElementById("div_push_local_net").style.display = "none";
	document.getElementById("div_set_remote_net").style.display = "block";
	document.getElementById("div_config_server_off_ip").style.display = "block";
	if (document.getElementById("id_act_pull").checked){
		document.getElementById("div_dhcp_client").style.display = "block";}
	else{
		document.getElementById("div_dhcp_client").style.display = "none";
		document.getElementById("id_act_dhcp_client").checked = false;
	}
	if (document.getElementById("id_act_dhcp_client").checked){
		document.getElementById("div_configure_ip").style.display = "none";}
	else{
		document.getElementById("div_configure_ip").style.display = "block";
	}
	if (document.getElementById("id_act_tap").checked){
		document.getElementById("div_ip_and_net").style.display = "inline";
		document.getElementById("div_ip_loc_rem").style.display = "none";
	}
	else {
		document.getElementById("div_ip_and_net").style.display = "none";
		document.getElementById("div_ip_loc_rem").style.display = "inline";
	}
    }
Consolidate_Vars();
}		
Init_Vars();Init_Table('tunclients_table');init_configs();Init_Checkbox();changeval();	
</script>
EOF

sec_end
