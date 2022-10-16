#!/bin/sh
VERSION="2.0.4_rc5"
FWVER=$(sed -rn 's/^export FIRMWARE_VERSION=.*(..)\.(..)/\1\2/p' /etc/version)


. /usr/lib/libmodcgi.sh
. /mod/etc/conf/avm-firewall.cfg
[ -r /etc/options.cfg ] && . /etc/options.cfg

SUBNET="
255.255.255.252
255.255.255.248
255.255.255.240
255.255.255.224
255.255.255.192
255.255.255.128
255.255.255.0
255.255.254.0
255.255.252.0
255.255.248.0
255.255.240.0
255.255.224.0
255.255.192.0
255.255.128.0
255.255.0.0
255.254.0.0
255.252.0.0
255.248.0.0
255.240.0.0
255.224.0.0
255.192.0.0
255.128.0.0
255.0.0.0
240.0.0.0
"

cat << EOF
<font size='1'>$(lang en:"This GUI is for router mode only and is based on the ar7.cfg file. Changes will be active after next reboot \(or after checking the box at the bottom of the page\)." de:"Oberfl&auml;che zur AVM-Firewall (nur im Routermodus) bearbeitet die ar7.cfg. &Auml;nderungen werden durch Reboot oder durch Auswahl am Ende der Seite aktiviert.")</font>

<script>
function byId(id) {
	return document.getElementById(id);
}
</script>
EOF

sec_begin "$(lang en:"Mode" de:"Ansicht")"
cat << EOF
<input id="e1" type="radio" name="fwmode" value="firewall" checked onclick='byId("new-fw-rule").style.display = "block"; byId("fw-rules").style.display = "block"; byId("new-forward-rule").style.display = "none"; byId("forward-rules").style.display = "none";'>
<label for="e1">Firewall</label>
<input id="e2" type="radio" name="fwmode" value="fwd" onclick='byId("new-forward-rule").style.display = "block"; byId("forward-rules").style.display = "block"; byId("new-fw-rule").style.display = "none"; byId("fw-rules").style.display = "none";'>
<label for="e2">Port Forwarding</label>
<div style="float: right;"><font size="1">Version: $VERSION</font></div>
EOF

sec_end

sec_begin "$(lang en:"Firewall add new rule" de:"Neue Firewall-Regel")" new-fw-rule
cat << EOF
<p>
<input type="hidden" name="gui" value="*gui*">
<table border="0">
<tr><td>$(lang en:"Source Address" de:"Quell-Adresse"): </td>
<td><select id="source_type" onchange='change_iptype(this.value, "id_ssubnet", "id_source"); build_new_rule()' > <option value="any">any</option>
    <option value="net">net</option> <option value="host">host</option>
</select></td>
<td><input type="text" name="source" id="id_source" size="18" maxlength="18" value="any" disabled onblur="onlynumpoint(this);build_new_rule()"></td>
<td>

EOF
# netmask for source
        echo '<select style="display:none" id="id_ssubnet" onchange="build_new_rule()">'
        for SUB in $SUBNET
        do
                echo '<option title="ssubnet" value="'$SUB'">'$SUB'</option>'
        done
        echo '</select> </td> </tr>'

cat << EOF
<tr><td>$(lang en:"Destination Address" de:"Ziel-Adresse"): </td>

<td><select id="dest_type" onchange='change_iptype(this.value, "id_dsubnet", "id_dest"); build_new_rule()'> <option value="any">any</option>
    <option value="net">net</option> <option value="host">host</option>
</select></td>
<td><input type="text" name="dest" id="id_dest" size="18" maxlength="18" value="any" disabled onblur="onlynumpoint(this);build_new_rule()"></td>
<td>

EOF

# netmask for destination
        echo '<select style="display:none" id="id_dsubnet" onchange="build_new_rule()">'
        for SUB in $SUBNET
        do
                echo '<option title="dsubnet" value="'$SUB'">'$SUB'</option>'
        done
cat << EOF
</select></td></tr>
<tr><td>$(lang en:"Protocol" de:"Protokoll"): </td><td><select name="protokoll" id="id_proto" onchange='document.getElementById("div_port").style.display= (this.value[0]=="i") ? "none" : "inline" ; build_new_rule()'>
    <option title="any" value="ip">any</option>
    <option title="tcp" value="tcp">tcp</option>
    <option title="udp" value="udp">udp</option>
    <option title="icmp" value="icmp">icmp</option>
    <option title="connection outgoing-related" value="ip">out-related</option>
    <option title="connection incoming-related" value="ip">in-related</option>
</select> </td>
<td colspan=2>
  <div id="div_port" style="display:none">
    (Start-)Port: <input size="5" id="id_sport" title="startport" value="" onblur="onlynum(this);build_new_rule()">
     &nbsp; &nbsp; (End-)Port: <input size="5" id="id_eport" title="endport" value="" onblur="onlynum(this);build_new_rule()">
  </div>
</td>
</tr>

<tr> <td> A$(lang en:"c" de:"k")tion: </td>
    <td><select name="action" id="id_action" onchange="build_new_rule()">
    <option title=$(lang en:"permit" de:"erlauben") value="permit">permit</option>
    <option title=$(lang en:"deny" de:"verwerfen") value="deny">deny</option>
    <option title=$(lang en:"reject" de:"abweisen") value="reject">reject</option>
</select></td> </tr>
</table>
<hr>
<p>$(lang en:"Rule" de:"Regel"): <input id="id_new_rule" size="85" value=""></p>
<p>$(lang en:"Insert as #" de:"Einf&uuml;gen an Platz"): <select id="id_where" size="1"> <option value=1>1</option> </select>
&nbsp; &nbsp; <input type="button" value="$(lang en:"Add rule" de:"Hinzuf&uuml;gen")" onclick='allrules.splice(document.getElementById("id_where").value -1, 0, document.getElementById("id_new_rule").value);rulescount += 1; Init_FW_Table();' />
</p>

EOF
echo $rulescount
sec_end

sec_begin "$(lang en:"Firewall rules" de:"Firewall-Regeln")" fw-rules
cat << EOF

<table width="100%"> <tr> <td><font color="red">$(lang en:"Incoming" de:"Eingehende Regeln")</font> (lowinput)<input type="radio" name="selectrules" id="id_li_rules" checked onclick='if (selrules=="ho"){allrules_ho=allrules}; selrules="li" ; allrules=allrules_li; Init_FW_Table()'>
 &nbsp; &nbsp; <font color="blue">$(lang en:"Outgoing" de:"Ausgehende Regeln")</font> (highoutput)<input type="radio" name="selectrules" id="id_ho_rules"
 	onclick='if (selrules=="li") {allrules_li=allrules}; selrules="ho" ; allrules=allrules_ho; Init_FW_Table()'></td>
 	<td align=right $([ $FWVER -ge 0476 ] && echo ' style="display:none"')> $(lang en:"Enable logging" de:"Logging einschalten") (<i>dsld -D</i>) <input type="hidden" name="log" value=""><input type="checkbox" name="log" value="yes" $([ "$AVM_FIREWALL_LOG" = yes ] && echo checked)> </td> </tr>
<tr><td> $(lang en:"For debugging show rules window" de:"Zum Debuggen Firewall-Regeln anzeigen"): &nbsp; LowInput <input type="checkbox" onclick='document.getElementById("id_rules_li").style.display=(this.checked)? "block" : "none"' >
 &nbsp; HighOutput <input type="checkbox" onclick='document.getElementById("id_rules_ho").style.display=(this.checked)? "block" : "none"' ></td>
 <td align=right $([ $FWVER -ge 0476 ] && echo ' style="display:none"')> $(lang en:"Log all dropped packets" de:"Verworfene Pakete loggen") (<b>no</b> <i>dsld -n</i>) <input type="hidden" name="log_dropped" value=""><input type="checkbox" name="log_dropped" value="yes" $([ "$AVM_FIREWALL_LOG_DROPPED" = yes ] && echo checked)> </td></tr>
</table>

<p><div align="center"><textarea id="id_rules_li" style="width: 600px; display:none" name="rulestable_li" rows="15" cols="80" wrap="off" ></textarea></div></p>
<input type="hidden" name="policy_li" id="id_policy_li" value="$AVM_FIREWALL_POLICY_LI">
<p><div align="center"><textarea id="id_rules_ho" style="width: 600px; display:none" name="rulestable_ho" rows="15" cols="80" wrap="off"></textarea></div></p>
<input type="hidden" name="policy_ho" id="id_policy_ho" value="$AVM_FIREWALL_POLICY_HO">

<p><div align="center"><b><font size='1'>$(lang en:"AVM default policy is \"permit\": Every packet not denied will pass. If you change this, you will have to \"reverse\" the rules and allow all desired traffic!" de:"AVM Standard-Regel ist \"permit\": Nur verbotene Pakete werden gesperrt. Wird dies ge&auml;ndert, m&uuml;ssen alle erw&uuml;nschten Pakete explizit erlaubt werden!")</font></b></div></p>
<br />

<table border="1" cellpadding="4" cellspacing="0" align="center" id="id_table_fwrules">
    <tr border="0"><td style="border-right:0" align="left" id="id_table_title" colspan="3"><font color="red">dslifaces rules lowinput</font></td><td style="border-left:0" align="right" colspan="4" >$(lang en:"<b>Default</b> policy" de:"Implizite <b>Standard</b>-Regel"):
 &nbsp; <b>Permit</b> <input type="radio" name="default_policy" value="permit" id="id_permit" onclick="policyclick()"> &nbsp; <b>Deny</b> <input type="radio" name="default_policy" value="deny" id="id_deny" onclick="policyclick()"> </td></tr>
    <tr> <th bgcolor="#bae3ff">#</th> <th bgcolor="#bae3ff">$(lang en:"Source" de:"Quelle")</th> <th bgcolor="#bae3ff">$(lang en:"Destination" de:"Ziel")</th> <th bgcolor="#bae3ff">$(lang en:"Protocol" de:"Protokoll")</th>
    <th bgcolor="#bae3ff">Service/Port</th> <th bgcolor="#bae3ff">A$(lang en:"c" de:"k")tion</th> <th bgcolor="#bae3ff">$(lang en:"&nbsp;&nbsp;&nbsp;Configure&nbsp;&nbsp;&nbsp;" de:"&nbsp;&nbsp;Bearbeiten&nbsp;&nbsp;")</th> </tr>
EOF
row=0
while [ $row -lt 50 ]; do
	cat << EOF
<tr style='display:none' id='id_row_$row'><td bgcolor='#CDCDCD' width='20' align='center' id='id_rownum_$row'>$row</td><td><input type='text' size='24' title='Source' onblur='rebuild_rule(this, "source", this.value);'></td><td><input type='text' size='24' title='Dest' onblur='rebuild_rule(this, "dest", this.value);'></td><td><select onchange='rebuild_rule(this, "proto", this.value);'><option value="ip">ip</option> <option value="tcp">tcp</option> <option value="udp">udp</option> <option value="icmp">icmp</option> </select></td><td><input type='text' size='13' title='Port' onblur='rebuild_rule(this, "param", this.value);'></td><td align='center'><table><tr><td align='center'><img id='id_act_img_$row' src='/images/deny.gif' onclick='SelAct(this)'></td></tr><tr><td ><font size=1 id='id_act_txt_$row'>DENY</font></td></tr></table></td><td bgcolor='#CAE7FB'>&nbsp;<img src='/images/del.png' title='delete rule' onclick='removerule(this)'>&nbsp;<img src='/images/clone.png' title='clone rule' onclick='cloneerule(this)'>&nbsp;<img src='/images/up.png' align='top' title='move rule up' onclick='moverule(this, allrules, -1); Init_FW_Table(); build_where_select();'>&nbsp;<img src='/images/down.png' title='move rule down' onclick='moverule(this, allrules, 1); Init_FW_Table(); build_where_select();'></td></tr>
EOF
	let row++
done
echo '</table>'

#EOF
sec_end

sec_begin "$(lang en:"Port forwarding add new rule" de:"Neue Port Forwarding-Regel")" new-forward-rule
cat << EOF
<p>
<table border="0">
<tr><td>$(lang en:"Protocol" de:"Protokoll"): </td><td><select name="fwdprotokoll" id="id_fwdproto" onchange=" (fdprot=this.value); build_new_fwdrule()">
	<option title="tcp" value="tcp">tcp</option>
	<option title="udp" value="udp">udp</option>
	<option title="gre" value="gre">gre</option>
	<option title="icmp" value="icmp">icmp</option>
</select> </td>
<td></td>
<td><div id="div_fwdsport">
&nbsp; &nbsp; (Start-)Port: <input size="5" id="id_fwd_in_sport" title="startport" value="22" onblur="onlynum(this);(fdsport=this.value);build_new_fwdrule()">
&nbsp; &nbsp; (End-)Port: <input type="text" size="5" id="id_fwd_in_eport" title="endport" value="" onblur="onlynum(this);fdeport=this.value;build_new_fwdrule()" >
</div></td>
</tr>
<tr><td>$(lang en:"Destination" de:"Ziel"): </td><td>
<select id="id_fwddest_type" onchange='(fddtype=this.value); build_new_fwdrule()'>
        <option value="fritz">Fritz!Box</option> <option value="host">host</option>
</select></td>
<td>&nbsp; <input type="text" disabled="disabled" id="id_fwddest" size="15" maxlength="15" value="0.0.0.0" onblur="onlynumpoint(this); fddest=this.value;build_new_fwdrule()">
</div></td>
<td>
<div id="div_fwddport" style="display:inline"> &nbsp; &nbsp; (Start-)Port: <input type="text" size="5" id='id_fwd_out_sport' value='22' onblur='onlynum(this);fdoport=this.value;build_new_fwdrule()'>
</div>
</td>
</tr>
<tr> <td>Name: </td><td colspan="3"> <input type="text" name="fwd_name" id="id_fwdname" size="18" maxlength="18" value="" onblur="fdname=this.value;build_new_fwdrule()"></td> </tr>
</p>
</table>
<hr>
<p>$(lang en:"Rule" de:"Regel"): <input id="id_new_fwdrule" size="65" value=""> &nbsp; &nbsp; <input type="button" value="$(lang en:"Add rule" de:"Hinzuf&uuml;gen")" onclick='allfwdrules.push(document.getElementById("id_new_fwdrule").value);fwdrulescount += 1; Init_FWDTable();' />
</p>

EOF
sec_end

sec_begin "$(lang en:"Port forwarding rules" de:"Port Forwarding-Regeln")" forward-rules
[ "$FREETZ_AVM_VERSION_05_5X_MIN" == "y" ] && echo "<p><small>$(lang en:"This firmware prevents forwarding to FTP (port 21) here. Use AVM webif instead." de:"Diese Firmware erm&ouml;glicht hier keine Freigabe f&uuml;r FTP (Port 21). Bitte das AVM Webif daf&uuml;r nutzen. <br> (Internet -> Freigaben -> FRITZBox-Dienste -> \"Internetzugriff auf Ihre Speichermedien &uuml;ber FTP/FTPS aktiviert\")") </small></p>"
cat << EOF

$(lang en:"For debugging show forwarding rules" de:"Zum Debuggen Forward-Regeln anzeigen"): <input type="checkbox" onclick='document.getElementById("forwardingrules").style.display=(this.checked)? "block" : "none"' >
<p><div align="center"><textarea id="forwardingrules" style="width: 600px; display:none;" name="forwardingrules" rows="15" cols="80" wrap="off" ></textarea></div></p>

<p><table width="100%" border="1" cellpadding="4" cellspacing="0" align="center" id="id_table_forwardrules">
        <tr><td align="left" colspan="8">dslifaces forwardrules</td></tr>
        <tr> <th bgcolor="#bae3ff">$(lang en:"Aktive" de:"Aktiv")</th> <th bgcolor="#bae3ff">$(lang en:"Protocol" de:"Protokoll")</th> <th bgcolor="#bae3ff">$(lang en:"Source Port" de:"Quell-Port")</th> <th bgcolor="#bae3ff">$(lang en:"Address" de:"Adresse")</th>
        <th bgcolor="#bae3ff">$(lang en:"Dest. Port" de:"Ziel-Port")</th> <th bgcolor="#bae3ff">$(lang en:"Description" de:"Beschreibung")</th> <th bgcolor="#bae3ff">$(lang en:"Configure" de:"Bearbeiten")</th> </tr>
        <tr style="display:none"><td bgcolor="#CDCDCD" width="40" align="center"><input type="checkbox" onclick='fwddisable[ (this.parentNode.parentNode.rowIndex -3)] = ! this.checked ; rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3));'></td><td><select onchange='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwdprot", this.value)'>
        <option value="icmp">icmp</option><option value="gre">gre</option><option value="tcp">tcp</option><option value="udp">udp</option>
        </select> </td><td><input type="text" size="10" title="SPort" onblur='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwdsport", this.value)'>
        </td><td><input type="text" size="24" title="Destination" onblur='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwddest", this.value)'>
        </td><td><input type="text" size="10" title="DPort" onblur='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwddport", this.value)'>
        </td><td><input type="text" title="Descr" onblur='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwdname", this.value)'>
</td><td><center><img src="/images/del.png" title="delete rule" onclick='allfwdrules.splice(this.parentNode.parentNode.parentNode.rowIndex -3 ,1); fwdrulescount -= 1;Init_FWDTable()'>
        </center></td>
	</tr>
</table></p>

EOF
#rm /var/tmp/firewall.*
cat << EOF

<script>
rules="";

action=new Array();
proto=new Array();
source=new Array();
dest=new Array();
param=new Array();
remark=new Array();
rulescount=0;
EOF
tmp="('$(echo "$AVM_FIREWALL_RULESTABLE_LI" | sed "s/$/', '/" | tr -d '\n' | sed "s/, '$//"))"
echo "allrules_li=new Array$tmp"
tmp="('$(echo "$AVM_FIREWALL_RULESTABLE_HO" | sed "s/$/', '/" | tr -d '\n' | sed "s/, '$//"))"
echo "allrules_ho=new Array$tmp"
echo "allfwdrules=new Array ($(sed -n '/dslifaces/,/} {/p' /var/flash/ar7.cfg | sed -n '/forwardrules/,/;/ {/shaper/ q; s/^[^"]*\(".*"\)[,;][ ]*/\1 , /gp}' | tr -d '\n' | sed 's/" ,[ ]*$/"/'))";
cat << EOF

policy_li="$AVM_FIREWALL_POLICY_LI";
policy_ho="$AVM_FIREWALL_POLICY_HO";
allrules=allrules_ho;
selrules="ho";
showrules();
allrules=allrules_li;
selrules="li";
byId("new-fw-rule").style.display = "block";
byId("fw-rules").style.display = "block";
byId("new-forward-rule").style.display = "none";
byId("forward-rules").style.display = "none";
Init_FW_Table()
build_new_rule()

fwdproto=new Array();
fwdsport=new Array();
fwddport=new Array();
fwddest=new Array();
fwddisable=new Array();
fwdname=new Array();

fdprot="tcp";
fdsport="22";
fdeport="";
fdoport="22";
fddtype="fritz";
fddest="0.0.0.0";
fdname='';

split_fwdrules();
Init_FWDTable();
build_new_fwdrule();

function onlynum(elem){
        elem.value=elem.value.replace(/[^0-9]+/g,'');
}

function onlynumpoint(elem){
        elem.value=elem.value.replace(/[^0-9\.]+/g,'');
}

function split_fwdrules(){
  count=0;
    while ( allfwdrules[count]){
            actrule=allfwdrules[count];
            splitrules=actrule.split(" ");
            if (splitrules[0]=="#") {fwddisable[count]=true ; next=1 } else {fwddisable[count]=false ; next=0 } ;
            fwdproto[count]=splitrules[next];
            if ( fwdproto[count] != "gre" && fwdproto[count] != "icmp" ) {fwdsport[count]=splitrules[(next+1)].split(":")[1]; fwddport[count]=splitrules[(next+2)].split(":")[1];}
            	else {fwdsport[count]=""; fwddport[count]=""};
            fwddest[count]=splitrules[(next+2)].split(":")[0];
            if (fwdname[count]=splitrules.slice(next+5).join(" ")){}else {fwdname[count]=""};
            count +=1 ;
    }
    fwdrulescount=count;
}
function build_new_fwdrule(){
 document.getElementById("div_fwddport").style.display = ( fdprot != "gre" && fdprot != "icmp" )? "inline" : "none";
 document.getElementById("div_fwdsport").style.display= ( fdprot != "gre" && fdprot != "icmp" )? "inline" : "none";
 document.getElementById("id_fwddest").disabled= ( fddtype != "fritz" )? "" : "disabled";

 var tmp=fdprot + " 0.0.0.0";
 if (fddtype == "fritz") {document.getElementById("id_fwddest").value="0.0.0.0"; fddest="0.0.0.0"};
 if ( fdprot != "gre" && fdprot != "icmp" ){ tmp +=":"+fdsport; if (fdeport > fdsport) {tmp+="+" + ((fdeport-fdsport)+1) } };
 tmp += " "+fddest;
 if ( fdprot != "gre" && fdprot != "icmp" ){tmp +=":"+fdoport;};
 if ( fdname != "" ){tmp +=" 0 # "+fdname;};
 document.getElementById("id_new_fwdrule").value = tmp;
}

function showfwdrules(){
  document.getElementById("forwardingrules").value=allfwdrules.join("\n");
}

function rebuild_fwdrule(num, name , val){
  if (name) { tmp=name +"[" + num + "] = '" + val +"'" ; eval (tmp)}
  allfwdrules[num]= (fwddisable[num]) ? "# " : "" ;
  allfwdrules[num]+=fwdproto[num]+" 0.0.0.0";
  allfwdrules[num]+= (fwdproto[num] == "gre" || fwdproto[num] == "icmp") ? " "+fwddest[num] : ":"+fwdsport[num]+" "+fwddest[num]+":"+fwddport[num];
  if (fwdname[num]){ allfwdrules[num] +=" 0 # "+fwdname[num] ;}
  showfwdrules();
}
function Init_FWDTable(){
  var number=Number(fwdrulescount);
  var tbl = document.getElementById("id_table_forwardrules");
  var lastRow = tbl.rows.length;
  split_fwdrules() ;
  for (j=3;j<=fwdrulescount+2;j++){
  	if (j >= lastRow) {var row = tbl.insertRow(j);for (i=0; i<=6 ; i++){row.appendChild(tbl.rows[2].cells[i].cloneNode(true))}};
  	tbl.rows[j].style.display='';

        cn=tbl.rows[j].childNodes;
        var el_active=cn[0].firstChild;
        var el_prot=cn[1].firstChild;
        var el_sport=cn[2].firstChild;
        var el_dest=cn[3].firstChild;
        var el_dport=cn[4].firstChild;
        var el_name=cn[5].firstChild;
        var lastel=cn[6].childNodes;
        var has_no_port=(fwdproto[j-3] == "gre" || fwdproto[j-3] == "icmp");
        el_active.checked=( !fwddisable[(j-3)] ) ? true : false;
        el_prot.value=fwdproto[j-3];
        el_sport.disabled=has_no_port;
        el_sport.value=fwdsport[j-3];
        el_dest.value=fwddest[j-3];
        el_dport.disabled=has_no_port;
        el_dport.value=fwddport[j-3];
        el_name.value=fwdname[j-3];
        for (i=0; i< lastel.length ; i++){
                switch (lastel[i].title){
                case "move rule up": lastel[i].style.display=(j==3) ? "none" : "inline"; break;
                case "move rule down": lastel[i].style.display=(j==fwdrulescount+2) ? "none" : "inline"; break;
                }
        }
  }
  for(j=lastRow-1;j>fwdrulescount+2;j--){
  	tbl.rows[j].style.display="none";
  }
  showfwdrules();
}

Init_FW_Table();

function my_tmp(elem){
var tmp=elem;
while (tmp.id !="content"){
	tmp=tmp.parentNode;}
cn=tmp.childNodes;
i=0;
while (i < cn.length && cn[i].className != "btn"){
i+=1;
}
cn[i].action='alert("ha, geaendert")';
newtmp=tmp.removeChild(cn[i]);
alert("ist weg");
}

function split_rules(){
  count=0;
  while ( allrules[count]){
    actrule=allrules[count].replace(/[/]\*.*\*[/][ ]*/,"");
    splitrules=actrule.split(" ");
    action[count]=splitrules[0];
    proto[count]=splitrules[1];
    source[count]=splitrules[2]; next=3;
    if ( source[count] != "any" ) {source[count]+= " " + splitrules[3]; next=4; };
    dest[count]=splitrules[next]; next+=1;
    if ( dest[count] != "any" ) {dest[count]+= " " + splitrules[next]; next+=1; };
    param[count]=splitrules.slice(next).join(" ");
    count += 1;
    }
  rulescount=count;
}

function moverule (elem, actrules, direct){
var num=+getmyrow(elem) - 1;
  if ((direct <0 && num >= 1) || (direct > 0 && num < actrules.length -1 )){
    var tmp=actrules[num];
    actrules[num]=actrules[num + direct];
    actrules[num + direct]=tmp;
  }
}

function getmyrow(elem){
var tmp=elem;
while (tmp.id.search("id_row_")==-1){
    tmp=tmp.parentNode;
}

return tmp.id.replace(/id_row_/,'');
}

function removerule(elem){
var index=+getmyrow(elem) - 1;
allrules.splice( index ,1); rulescount -= 1;Init_FW_Table(); build_where_select();
}

function cloneerule(elem){
var index=+getmyrow(elem) - 1;
var tmprule=allrules[index];
allrules.splice(index, 0, tmprule);rulescount += 1; Init_FW_Table();
}

function SelAct(elem){
var index=+getmyrow(elem) - 1;
act="dummy"
switch (action[index]){
    case "deny": act="reject"; break
    case "reject": act="permit"; break
    case "permit": act="deny"; break
}

rebuild_rule(elem, "action", act);
elem.src="/images/"+act+".gif"
elem.title=act.toUpperCase();
var tmpid="id_act_txt_"+ (+index +1);
tmp=document.getElementById(tmpid);
tmp.firstChild.nodeValue=act.toUpperCase();
}

function build_new_rule(){
  elem_proto=document.getElementById("id_proto");
  tmp=document.getElementById("id_action").value + " " + elem_proto.value + " ";
  switch ( document.getElementById("source_type").value ){
    case "host": tmp += "host " + document.getElementById("id_source").value + " "; break;
    case "net": tmp += document.getElementById("id_source").value + " "+ document.getElementById("id_ssubnet").value + " "; break;
    case "any": tmp += "any " ; break;
  }
  switch ( document.getElementById("dest_type").value ){
        case "host": tmp += "host " + document.getElementById("id_dest").value; break;
        case "net": tmp += document.getElementById("id_dest").value + " "+ document.getElementById("id_dsubnet").value; break;
        case "any": tmp += "any" ; break;
  }
  if ( elem_proto.value.charAt(0) != "i" ){
    eport = document.getElementById("id_eport").value ;
    if ( eport != "" ) { tmp += " range "} else { tmp += " eq "} ;
    tmp += document.getElementById("id_sport").value ;
    if ( eport !="" ) { tmp += " " + eport } ;
  }
  else {
    txt=elem_proto.options[elem_proto.selectedIndex].title;
    if (txt.charAt(0) == "c" ){
    tmp += " " + txt
    }
  }
  document.getElementById("id_new_rule").value = tmp;
}

function build_where_select(){
  element=document.getElementById("id_where");
  l=element.length;
  if ( l < rulescount+1 ) {
    for (j=l ; j< rulescount+1 ; j++){
        newopt=document.createElement('option');
        newopt.text= (j+1);
        newopt.value= (j+1);
        element.options[j]= newopt;
    }
  }
  else if ( l > rulescount+1 ){
    for (j=l ; j >= rulescount+1 ; j--){
                element.options[j]= null ;
    }
  }
}

function change_iptype(val, div_id, ip_id){
  div_el=document.getElementById(div_id).style.display= (val.charAt(0)=="n") ? "inline" : "none";
  var ip_el=document.getElementById(ip_id);
  ip_el.value= (val.charAt(0)=="a") ? "any" : "";
  ip_el.disabled= (val.charAt(0)=="a") ? true : false;
}

function showrules(){
  var is_li=(selrules=="li");
  var tmp="";
  for (i=0; i<allrules.length ; i++){
      tmp += allrules[i]+'\n';
  }
  var id="id_rules_"+selrules;
  document.getElementById(id).value=tmp;
}

function rebuild_rule(elem, name , val){
  var num=+getmyrow(elem) - 1;
  if (name && val) { tmp=name +"[" + num + "] = '" + val +"'" ; eval (tmp)}
  tmp=allrules[num].match(/[/]\*.*\*[/]/);
  allrules[num]=action[num]+" "+proto[num]+" "+source[num]+" "+dest[num];
  if (proto[num].charAt(0) != "i" || (param[num].search(/connection/) != -1) ) { allrules[num]+=" "+param[num]};
  if (tmp) { allrules[num]+=tmp+" ";};
  showrules();
}

function Init_FW_policy(){
	pol= (selrules=="li")? policy_li : policy_ho;
	var tmpid="id_"+pol;
	document.getElementById(tmpid).checked=true;
}

function policyclick(){
	var tmp=document.getElementsByName("default_policy");
	var pol=(document.getElementById("id_permit").checked)? "permit" : "deny"
	if (selrules=="li") {policy_li = pol; document.getElementById("id_policy_li").value=pol;}
	else {policy_ho = pol; document.getElementById("id_policy_ho").value=pol;}
}

function Init_FW_Table(){
  var number=Number(rulescount);
  var tbl = document.getElementById("id_table_fwrules");
  var lastRow = tbl.rows.length;
  var row;
  document.getElementById("id_table_title").innerHTML="dslifaces rules \"" + ((selrules=="li") ? "<font color=\"red\"><b>lowinput" : "<font color=\"blue\"><b>highoutput")+'</b></font>"';
  split_rules();
  Init_FW_policy();
        for (j=3;j<=rulescount+2;j++){
          if (j >= lastRow) {
              row = tbl.insertRow(j);
              var tmpid = "id_row_"+ (j-2)+'';
              row.setAttribute("id", tmpid);
              for (i=0; i<=6 ; i++){
                  row.appendChild(tbl.rows[2].cells[i].cloneNode(true))
              };
              row.childNodes[0].innerHTML=j-2+"";
              action_rows=row.childNodes[5].firstChild.firstChild.rows;
              action_rows[0].firstChild.firstChild.id="id_act_img_"+(j-2)+"";
              action_rows[1].firstChild.firstChild.id="id_act_txt_"+(j-2)+"";

          };

            tbl.rows[j].style.display='';
            cn=tbl.rows[j].childNodes;
            cn[0].innerHTML=j-2+"";
            cn[1].firstChild.value=source[j-3];
            cn[2].firstChild.value=dest[j-3];
            cn[3].firstChild.value=proto[j-3];
            cn[4].firstChild.value=param[j-3];
            tmpid="id_act_img_"+(j-2);
            document.getElementById(tmpid).src="/images/"+action[j-3]+".gif";
            tmpid="id_act_txt_"+(j-2);
            document.getElementById(tmpid).firstChild.nodeValue=action[j-3].toUpperCase();
            var lastel=cn[6].childNodes;
            for (i=0; i< lastel.length ; i++){
                switch (lastel[i].title){
                    case "move rule up": lastel[i].style.display=(j==3) ? "none" : "inline"; break;
                    case "move rule down": lastel[i].style.display=(j==rulescount+2) ? "none" : "inline"; break;
                }
            }

        }
                for(j=lastRow-1;j>rulescount+2;j--){
                tbl.rows[j].style.display="none";
        }

        showrules();
        build_where_select();
}
</script>
EOF
sec_end
cat << EOF
<font size="1">$(lang en:"\"Defaults\" will load AVM default firewall rules (only loads into this GUI, use \"Apply\" to save them)" de:"\"Standard\" l&auml;dt AVM Default-Regeln in die GUI. Zum Speichern \"&Uuml;bernehmen\"-Knopf dr&uuml;cken").</font><br />
<input type="hidden" name="do_activate" value=""></font>
$(lang en:"Saving will <b>not</b> activate rules or new dsld switches by default! <b>To do so, some daemoms have to be restarted:</b>" de:"Regelwerk und dsld Schalter werden standardm&auml;&szlig;ig <b>nicht</b> aktiviert!  Dazu m&uuml;ssen AVM-Dienste neu gestartet werden:") <br />
<img src="/images/blink!.gif" title="Attention!" valign="center"> &nbsp; <b>$(lang en:"This might crash your box or even restore factory defaults!" de:"Das kann zum Absturz oder sogar zum Werksreset f&uuml;hren!") </b> &nbsp;&nbsp;&nbsp; $(lang en:"Activate rules directly after saving" de:"Regeln gleich nach Speichern aktivieren") <input type="checkbox" value="dsld_ctlmgr" name="do_activate" ><br />
<font size="1">($(lang en:"Safe way to activate the settings is only save them here and then restart the box" de:"Um die &Auml;nderungen \"sicher\" zu aktivieren, hier nur \"&Uuml;bernehmen\" w&auml;hlen und dann die Box neu starten"))</font><br />
EOF

