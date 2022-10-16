#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$VPNC_ENABLED" yes:auto "*":man
check "$VPNC_IKEDHGROUP" dh1:ike1
check "$VPNC_IKEDHGROUP" dh2:ike2
check "$VPNC_IKEDHGROUP" dh5:ike5
if [ -z "$VPNC_NETWORK" ]; then VPNC_NETWORK='0.0.0.0'; fi
if [ -z "$VPNC_MASK" ]; then VPNC_MASK='0.0.0.0'; fi
check "$VPNC_PERFECTFORWARDSECRECY" nopfs:pfs_nopfs
check "$VPNC_PERFECTFORWARDSECRECY" dh1:pfs_dh1
check "$VPNC_PERFECTFORWARDSECRECY" dh2:pfs_dh2
check "$VPNC_PERFECTFORWARDSECRECY" dh5:pfs_dh5
check "$VPNC_PERFECTFORWARDSECRECY" server:pfs_server
check "$VPNC_UDPENCAPSULATE" yes:udpenc_on "*":udpenc_off
check "$VPNC_ENABLESINGLEDES" yes:en_single_des_on "*":en_single_des_off
check "$VPNC_DISABLENATTRAVERSAL" yes:dis_nat_trav_on "*":dis_nat_trav_off

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end
sec_begin 'VPNC - VPN Client'

cat << EOF
<h2>VPN Benutzer-Daten</h2>
<p>IPSec Gruppenname: <input type="text" name="ipsecid" size="15" maxlength="30" value="$(html "$VPNC_IPSECID")"></p>
<p>IPSec Gruppenpasswort: <input type="password" name="ipsecsecret" size="15" maxlength="35" value="$(html "$VPNC_IPSECSECRET")"></p>
<p>Benutzername: <input type="text" name="xauthusername" size="15" maxlength="40" value="$(html "$VPNC_XAUTHUSERNAME")"></p>
<p>Benutzerpasswort: <input type="password" name="xauthpassword" size="15" maxlength="35" value="$(html "$VPNC_XAUTHPASSWORD")"></p>
<h2>VPN Server-Daten</h2>
<p>IP/Name des IPSec Gateway<br>
IPSec gateway: <input type="text" name="ipsecgateway" size="15" maxlength="30" value="$(html "$VPNC_IPSECGATEWAY")"> &lt;IP/Name&gt;</p>
<p>Name der IKE DH Group<br>
IKE DH Group:
<input id="ike1" type="radio" name="ikedhgroup" value="dh1"$ike1_chk><label for="ike1"> dh1</label>
<input id="ike2" type="radio" name="ikedhgroup" value="dh2"$ike2_chk><label for="ike2"> dh2</label>
<input id="ike5" type="radio" name="ikedhgroup" value="dh5"$ike5_chk><label for="ike5"> dh5</label>
</p>
<p>Diffie-Hellman Gruppe f&uuml;r PFS<br>
Perfect Forward Secrecy:
<input id="pfs1" type="radio" name="perfectforwardsecrecy" value="nopfs"$pfs_nopfs_chk><label for="pfs1"> nopfs</label>
<input id="pfs2" type="radio" name="perfectforwardsecrecy" value="dh1"$pfs_dh1_chk><label for="pfs2"> dh1</label>
<input id="pfs3" type="radio" name="perfectforwardsecrecy" value="dh2"$pfs_dh2_chk><label for="pfs3"> dh2</label>
<input id="pfs4" type="radio" name="perfectforwardsecrecy" value="dh5"$pfs_dh5_chk><label for="pfs4"> dh5</label>
<input id="pfs5" type="radio" name="perfectforwardsecrecy" value="server"$pfs_server_chk><label for="pfs5"> server</label>
</p>
<p>Lokale ISAKMP Portnummer (0 == zuf&auml;llig)<br>
Local Port: <input type="text" name="localport" size="15" maxlength="15" value="$(html "$VPNC_LOCALPORT")"> &lt;0-65535&gt;</p>
<p>IPSEC mit Cisco-UDP Encapsulation nutzen<br>
UDP Encapsulate:
<input id="udpe1" type="radio" name="udpencapsulate" value="yes"$udpenc_on_chk><label for="udpe1"> an</label>
<input id="udpe2" type="radio" name="udpencapsulate" value="no"$udpenc_off_chk><label for="udpe2"> aus</label>
</p>
<p>Aktiviere schwache single DES Verschl&uuml;sselung<br>
Enable Single DES:
<input id="esd1" type="radio" name="enablesingledes" value="yes"$en_single_des_on_chk><label for="esd1"> an</label>
<input id="esd2" type="radio" name="enablesingledes" value="no"$en_single_des_off_chk><label for="esd2"> aus</label>
</p>
<p>Deaktiviere Nutzung von NAT-T<br>
Disable NAT Traversal:
<input id="dnt1" type="radio" name="disablenattraversal" value="yes"$dis_nat_trav_on_chk><label for="dnt1"> an</label>
<input id="dnt2" type="radio" name="disablenattraversal" value="no"$dis_nat_trav_off_chk><label for="dnt2"> aus</label>
</p>
<p>(NT-) Domainname f&uuml;r Authentisierung (optional) <br>
Domain: <input type="text" name="domain" size="15" maxlength="15" value="$(html "$VPNC_DOMAIN")"> </p>
<p>Hersteller deines IPSec Gateways (optional) <br>
Vendor: <input type="text" name="vendor" size="15" maxlength="15" value="$(html "$VPNC_VENDOR")"> </p>
<p>Remote Network f&uuml;r vpnc-script (Tunnel-Route)<br>
Network: <input type="text" name="network" size="15" maxlength="15" value="$(html "$VPNC_NETWORK")"><br>
Mask: <input type="text" name="mask" size="15" maxlength="15" value="$(html "$VPNC_MASK")"> </p>
EOF

sec_end
