#!/bin/sh
VERSION="2.0.3c"
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/var/mod/sbin
CONFIG=/mod/etc/conf/avm-firewall.cfg
. /usr/lib/libmodcgi.sh
. /mod/etc/conf/avm-firewall.cfg

SUBNET="255.255.255.252 255.255.255.248 255.255.255.240 255.255.255.224 \
        255.255.255.192 255.255.255.128 255.255.255.0 255.255.254.0 255.255.252.0 255.255.248.0 255.255.240.0 255.255.225.0 \
        255.255.192.0 255.255.128.0 255.255.0.0"

echo "<font size='1'>$(lang en:"This firewall is for router mode only and is based on the ar7.cfg file of AVM. New rule settings will be active after next reboot or after clicking the \"Activate Button\" below." de:"Oberfl&auml;che zur AVM-Firewall (nur im Routermodus) bearbeitet die ar7.cfg. &Auml;nderungen werden durch Reboot oder durch Auswahl am Ende der Seite aktiviert")</font>"

sec_begin '$(lang de:"Neue Firewall Regel" en:"Firewall add new rule")'
cat << EOF
<div style="float: right;"><font size="1">Version: $VERSION</font></div>
<p>
<input type="hidden" name="gui" value="*gui*">
<table border="0">
EOF

cat << EOF
<tr><td>$(lang en:"Source Address" de:"Absende-Adresse")</td>
<td><select id="source_type" onchange='change_iptype(this.value, "id_ssubnet", "id_source"); build_new_rule()' > <option value="any">any</option>  
    <option value="net">net</option>   <option value="host">host</option>
</select></td>
<td><input type="text" name="source" id="id_source" size="18" maxlength="18" value="any" disabled onblur="build_new_rule()"></td>
<td>

EOF
# netmask for source
        echo '<select style="display:none"  id="id_ssubnet" onchange="build_new_rule()">'
         for SUB in $SUBNET
        do
                echo '<option title="ssubnet" value="'$SUB'">'$SUB'</option>'
        done
        echo '</select> </td> </tr>'

cat << EOF
<tr><td>$(lang en:"Destination Address" de:"Ziel-Adresse")</td>

<td><select id="dest_type" onchange='change_iptype(this.value, "id_dsubnet", "id_dest"); build_new_rule()'> <option value="any">any</option>
        <option value="net">net</option>   <option value="host">host</option>
</select></td>
<td><input type="text" name="dest" id="id_dest" size="18" maxlength="18" value="any" disabled onblur="build_new_rule()"></td>
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
<tr><td>$(lang en:"Protocol" de:"Protokoll")</td><td><select name="protokoll" id="id_proto" onchange='document.getElementById("div_port").style.display= (this.value[0]=="i") ? "none" : "inline" ; build_new_rule()'>
    <option title="any" value="ip">any</option>
    <option title="tcp" value="tcp">tcp</option>
    <option title="udp" value="udp">udp</option>
    <option title="icmp" value="icmp">icmp</option>
</select> </td>
<td colspan=2>
  <div id="div_port" style="display:none">
    (Start-)Port <input size="5" id="id_sport" title="startport" value="" onblur="build_new_rule()">
     &nbsp; &nbsp; ( End-Port <input size="5" id="id_eport"  title="endport" value="" onblur="build_new_rule()" > )
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
$(lang en:"Rule" de:"Regel"): <input id="id_new_rule" size="90" value="">
<p>$(lang en:"Insert as #" de:"Einf&uuml;gen an Platz") <select id="id_where" size="1"> <option value=1>first</option> </select>
&nbsp; &nbsp; <input type="button" value=$(lang en:"ADD Rule" de:"Hinzuf&uuml;gen") onclick='allrules.splice(document.getElementById("id_where").value -1, 0, document.getElementById("id_new_rule").value);rulescount +=  1; Init_FW_Table();' />
</p>

EOF
echo $rulescount
sec_end

sec_begin 'Firewall $(lang en:"rules" de:"Regeln")'
cat << EOF
 
<p><table width="100%"> <tr> <td><font color="red">$(lang en:"Incoming" de:"Eingehende Regeln")</font> (lowinput)<input type="radio" name="selectrules" id="id_li_rules" checked onclick='if (selrules=="ho"){allrules_ho=allrules}; selrules="li" ; allrules=allrules_li; Init_FW_Table()'>  
 &nbsp;  &nbsp;   <font color="blue">$(lang en:"Outgoing" de:"Ausgehede Regeln")</font> (highoutput)<input type="radio" name="selectrules" id="id_ho_rules" 
 	onclick='if (selrules=="li") {allrules_li=allrules}; selrules="ho" ; allrules=allrules_ho; Init_FW_Table()'></td> 
 	<td align=right> $(lang en:"Enable " de:"")logging $(lang en:"feature" de:"einschalten") (<i>dsld -D</i>)  <input type="hidden" name="log" value=""><input type="checkbox" name="log" value="yes"> </td> </tr></table> 
<br /> $(lang en:"For Debugging : show Rules-Window" de:"nur zum debuggen: Regelwerk anzeigen")  &nbsp;  &nbsp; LowInput: <input type="checkbox" onclick='document.getElementById("id_rules_li").style.display=(this.checked)? "block" : "none"' >
 &nbsp; HighOutput:  <input type="checkbox" onclick='document.getElementById("id_rules_ho").style.display=(this.checked)? "block" : "none"' >
</p>

<textarea id="id_rules_li" style="width: 600px; display:none" name="rulestable_li" rows="15" cols="80" wrap="off" ></textarea>
<input type="hidden" name="policy_li" id="id_policy_li" value="$AVM_FIREWALL_POLICY_LI">
<textarea id="id_rules_ho" style="width: 600px; display:none" name="rulestable_ho" rows="15" cols="80" wrap="off"></textarea>
<input type="hidden" name="policy_ho" id="id_policy_ho" value="$AVM_FIREWALL_POLICY_HO">
<br />
<p>
<font size='1'>$(lang en:"AVM default-policy is \"permit\": every packet not denied will pass. If you change this, you will have to \"reverse\" the rules and allow all desired traffic!!!" de:"AVM Standard-Regel ist \"permit\": nur verbotene Pakete werden gesperrt. Wird dies ge&auml;ndert, m&uuml;ssen alle erw&uuml;nschten Pakete explizit erlaubt werden!")</font>
<br />
</p>
<table border="1" cellpadding="4" cellspacing="0" align="center" id="id_table_fwrules">
    <tr  border="0"><td  style="border-right:0" align="left" id="id_table_title" colspan="3"><font color="red">dslifaces lowinput</font></td><td style="border-left:0 ; border-right:0" colspan="4" >$(lang en:"Default Policy" de:"Implizite Standardregel"):
    &nbsp;  &nbsp; Permit <input type="radio" name="default_policy" value="permit" id="id_permit" onclick="policyclick()"> &nbsp;  &nbsp; &nbsp;  &nbsp;  Deny <input type="radio" name="default_policy" value="deny" id="id_deny"  onclick="policyclick()"> </td></tr> 
    <tr> <th bgcolor="#bae3ff">#</th> <th bgcolor="#bae3ff">$(lang en:"Source" de:"Absender")</th> <th bgcolor="#bae3ff">$(lang en:"Destination" de:"Ziel")</th> <th bgcolor="#bae3ff">$(lang en:"Protocol" de:"Protokoll")</th>
    <th bgcolor="#bae3ff">Service/PORT</th> <th bgcolor="#bae3ff">A$(lang en:"c" de:"k")tion</th> <th bgcolor="#bae3ff">$(lang en:"Configure" de:"Bearbeiten")</th> </tr>
EOF
row=0
while [ $row -lt 50 ]; do
    echo -n "<tr style='display:none' id='id_row_$row'><td bgcolor='#CDCDCD' width='20' align='center' id='id_rownum_$row'>$row</td>"
    echo -n "<td><input type='text' size='24' title='Source' onblur='rebuild_rule ( this , \"source\" ,this.value);'></td>"
    echo -n "<td><input type='text' size='24' title='Dest'  onblur='rebuild_rule ( this , \"dest\" ,this.value);'></td>"
    echo -n "<td><select  onchange='rebuild_rule ( this , \"proto\" ,this.value);'>"
    echo -n '<option value="ip">ip</option> <option value="tcp">tcp</option> <option value="udp">udp</option> <option value="icmp">icmp</option> </select>'
    echo -n "</td><td><input type='text' size='13' title='Port' onblur='rebuild_rule ( this, \"param\" ,this.value);'></td><td align='center'>"
    echo -n "<table><tr><td align='center'><img  id='id_act_img_$row' src='../images/deny.gif' onclick='SelAct(this)'></td></tr><tr><td ><font size=1 id='id_act_txt_$row'>DENY</font></td></tr></table>"
    echo -n "</td><td bgcolor='#CAE7FB'>&nbsp;<img src='../images/del.jpg'  title='delete rule' onclick='removerule(this)'>"
    echo -n "&nbsp;<img src='../images/clone.jpg'  title='clone rule' onclick='cloneerule(this)'>"
    echo -n "&nbsp;<img src='../images/up.jpg' align='top' title='move rule up' onclick='moverule(this, allrules, -1 );Init_FW_Table(); build_where_select();'>"
    echo  "&nbsp;<img src='../images/down.jpg'  title='move rule down' onclick='moverule(this, allrules, 1 );Init_FW_Table(); build_where_select();'></td></tr>"
row=$(($row+1))
done
echo '</table>'

#EOF
sec_end
 

#rm /var/tmp/firewall.*
cat << EOF

<script>
/*
console.time("mytime");
*/
rules="";

action=new Array();
proto=new Array();
source=new Array();
dest=new Array();
param=new Array();
remark=new Array();
rulescount=0;
EOF
tmp="('""`echo "$AVM_FIREWALL_RULESTABLE_LI"| sed "s/$/', '/" | tr -d '\n'| sed "s/, '$//"`"')'
echo "allrules_li=new Array$tmp"
tmp="('""`echo "$AVM_FIREWALL_RULESTABLE_HO"| sed "s/$/', '/" | tr -d '\n'| sed "s/, '$//"`"')'
echo "allrules_ho=new Array$tmp"
cat << EOF
policy_li="$AVM_FIREWALL_POLICY_LI";
policy_ho="$AVM_FIREWALL_POLICY_HO";
allrules=allrules_ho;
selrules="ho";
showrules();
allrules=allrules_li;
selrules="li";
 

Init_FW_Table();
/*
console.timeEnd("mytime");
console.time("mytime");
*/

/*
console.timeEnd("mytime");
*/

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
while  (tmp.id.search("id_row_")==-1){
    tmp=tmp.parentNode;
}

return tmp.id.replace(/id_row_/,'');
}

function removerule(elem){
var index=+getmyrow(elem) - 1;
allrules.splice( index ,1); rulescount -=  1;Init_FW_Table();  build_where_select();
}

function cloneerule(elem){
var index=+getmyrow(elem) - 1;
var tmprule=allrules[index];
allrules.splice(index, 0, tmprule);rulescount +=  1; Init_FW_Table();
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
elem.src="../images/"+act+".gif"
elem.title=act.toUpperCase();
var tmpid="id_act_txt_"+ (+index +1);
tmp=document.getElementById(tmpid);
tmp.firstChild.nodeValue=act.toUpperCase();
}


function build_new_rule(){
  tmp=document.getElementById("id_action").value + " " + document.getElementById("id_proto").value + " ";
  switch ( document.getElementById("source_type").value ){
    case "host": tmp += "host " + document.getElementById("id_source").value + " "; break;
    case "net": tmp +=  document.getElementById("id_source").value + " "+ document.getElementById("id_ssubnet").value + " "; break;
    case "any": tmp += "any " ; break;
  }
  switch ( document.getElementById("dest_type").value ){
        case "host": tmp += "host " + document.getElementById("id_dest").value; break;
        case "net": tmp +=  document.getElementById("id_dest").value + " "+ document.getElementById("id_dsubnet").value; break;
        case "any": tmp += "any" ; break;
  }
  if ( document.getElementById("id_proto").value.charAt(0) != "i" ){
    eport = document.getElementById("id_eport").value ;
    if ( eport != "" ) { tmp += " range "} else { tmp += " eq "} ;
    tmp += document.getElementById("id_sport").value ;
    if ( eport !="" ) { tmp += " " + eport } ;
  }
  document.getElementById("id_new_rule").value = tmp;
}

function build_where_select(){
  element=document.getElementById("id_where");
  l=element.length;
  if (  l < rulescount+1 ) {
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
  if (proto[num].charAt(0) != "i") { allrules[num]+=" "+param[num]};
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
	if (selrules=="li") {policy_li = pol;  document.getElementById("id_policy_li").value=pol;}
	else  {policy_ho = pol;  document.getElementById("id_policy_ho").value=pol;}
}

function Init_FW_Table(){
  var number=Number(rulescount);
  var tbl = document.getElementById("id_table_fwrules");
  var lastRow = tbl.rows.length;
  var row;
  document.getElementById("id_table_title").innerHTML="dslifaces Rules \"" + ((selrules=="li") ? "<font color=\"red\"><b>lowinput" : "<font color=\"blue\"><b>highoutput")+'</b></font>"';
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
            document.getElementById(tmpid).src="../images/"+action[j-3]+".gif";
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
<font size="1">$(lang en:"\"Defaults\" will load AVM default firewall rules (only load into this GUI, use \"Apply\" to save them)" de:"\"Standard\" l&auml;dt AVM Default-Regeln in die GUI. Zum Speichern \"&Uuml;bernehmen\"-Knopf dr&uuml;cken").</font><br />
<input type="hidden" name="do_activate" value="">
$(lang en:"Saving will <b>not</b> activate new rules by default! Check to activate rules when saving" de:"Regeln werden beim Speichern standardm&auml;&szlig;ig <b>nicht aktiviert</b>! Zum Aktivieren hier klicken: ")<input type="checkbox" value="yes"  name="do_activate" >
<img src="../images/blink!.gif" title="Attention!" valign="center">&nbsp;<font size="1">$(lang en:"(Sometimes Box will reboot)" de:"(Kann zum Reboot f&uuml;hren!)")</font>
EOF
