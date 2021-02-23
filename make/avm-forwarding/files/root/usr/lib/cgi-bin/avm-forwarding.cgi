#!/bin/sh
VERSION="0.0.1_alpha1"
# FW-Version als Zahl (xx.05.22 wird zu 522, xx.05.55 zu 555 usw)
FWVER=$(/etc/version | sed 's/[0-9]*\.[0]*// ; s/\.//')

. /usr/lib/libmodcgi.sh
. /mod/etc/conf/avm-forwarding.cfg
[ -r /etc/options.cfg ] && . /etc/options.cfg

cat << EOF
<input type="hidden" name="gui" value="*gui*">
<font size='1'>$(lang en:"This GUI requires at least one active forwarding to the box itself. You might (temporarily) allow HTTPS access in AVM GUI." de:"Diese Oberfl&auml;che ben&ouml;tigt mindestens eine aktive Weiterleitung auf die Box. Z.B. kann (tempor&auml;r) der HTTPS Zugriff in der AVM-GUI erlaubt werden (Internet -> Freigaben -> FRITZBox-Dienste).")</font>

<script>
function byId(id) {
	return document.getElementById(id);
}
</script>
EOF

sec_begin "$(lang en:"Important" de:"Wichtiger Hinweis")" new-forward-rule
cat << EOF
$(lang en:"Please note that there is no (known) reliable way to enable port forwarding to the Fritzbox without doing severe modifications to the AVM configuration files. This results in a risk that these changes might render the AVM settings unusable. In addition, the regular firmware might overwrite the settings made here.
<br>
It is therefore strongly recommended not to use the regular AVM GUI simultaneously with this GUI (no matter which web page).
Please close all other web sessions to the box and reboot it asap after making changes using this GUI.
<br><br>
This package will only open ports to the fritzbox itself. To forward ports to other devices use the AVM GUI instead!" de:"Bitte beachten Sie, dass es keine (bekannte) M&ouml;glichkeit gibt, eine Weiterleitung auf die Fritzbox selbst ohne tiefgreifende Eingriffe in die Konfigurationsdateien zu erm&ouml;glichen. Damit ergibt sich ein besonderes Risiko, mit Einstellungen auf dieser Seite die Einstellungen der Fritzbox unbrauchbar zu machen. Zudem wird jede Einstellung auf der Fritzbox die hier gemachten Einstellungen &uuml;berschreiben.
<br>
Es ist daher dringend anzuraten, die \"normale\" AVM GUI nicht gleichzeitig mit dieser GUI zu benutzen (egal welche Seite).
Am besten beenden Sie zuvor alle anderen Zugriffe auf die Box und f&uuml;hren sofort nach der &Uuml;bernahme der &Auml;nderung einen Reboot der Box durch.<br><br>Nur Ports (Dienste) auf der Box selbst k&ouml;nnen freigegeben werden. Weiterleitungen zu anderen Ger&auml;ten erm&ouml;glicht nur die AVM-GUI!")
EOF
sec_end
sec_begin "$(lang en:"Open new port on fritzbox" de:"Neue Port Freigabe auf der Fritzbox")" new-forward-rule
cat << EOF
<table><tr><td>
 <select name="fwdprotokoll" id="id_fwdproto" onchange=" (fdprot=this.value); build_new_fwdrule()">
	<option title="tcp" value="tcp">tcp</option>
	<option title="udp" value="udp">udp</option>
	<option title="gre" value="gre">gre</option>
	<option title="icmp" value="icmp">icmp</option>
</select></td><td><div id="div_fwdsport"> &nbsp; &nbsp; Port: <input size="5" id="id_fwd_in_sport" title="startport" value="22" onblur="onlynumplus(this);(fdsport=this.value);build_new_fwdrule()">
</div></td><td>
<div id="div_fwddport" style="display:inline"> &nbsp; &nbsp; $(lang en:"Destination port" de:"Ziel Port"): <input type="text" size="5" id='id_fwd_out_sport' value='22' onblur='onlynum(this);fdoport=this.value;build_new_fwdrule()'>
</div></td><td>
&nbsp; &nbsp; 
Name: <input type="text" name="fwd_name" id="id_fwdname" size="18" maxlength="18" value="" onblur="fdname=this.value;build_new_fwdrule()">
</td><td>
&nbsp; &nbsp;
<input id="id_new_fwdrule" size="60" type="hidden" value=""> &nbsp; &nbsp; <input type="button" value="$(lang en:"Add rule" de:"Regel hinzuf&uuml;gen")" onclick='allfwdrules.push(document.getElementById("id_new_fwdrule").value);fwdrulescount += 1; Init_FWDTable();' />
</td></tr></table>

EOF
sec_end

sec_begin "$(lang en:"Port forwarding rules to box itself" de:"Port Forwarding-Regeln auf die Fritzbox")" forward-rules
[ $FWVER -ge 550 ] && echo "<p><small>$(lang en:"This firmware prevents opening FTP port (21) here. Use AVM webif instead." de:"Diese Firmware erm&ouml;glicht hier keine Freigabe des FTP-Ports (21). Bitte das AVM Webif daf&uuml;r nutzen. <br> (Internet -> Freigaben -> FRITZBox-Dienste -> \"Internetzugriff auf Ihre Speichermedien &uuml;ber FTP/FTPS aktiviert\")") </small></p>"
cat << EOF

$(lang en:"For debugging show forwarding rules" de:"Zum Debuggen Forward-Regeln anzeigen"): <input type="checkbox" onclick='document.getElementById("rules").style.display=(this.checked)? "block" : "none"' >
<p><div align="center"><textarea id="rules" style="width: 500px; display:none;" name="rules" rows="15" cols="80" wrap="off" ></textarea></div></p>

<p><table width="100%" border="1" cellpadding="4" cellspacing="0" align="center" id="id_table_forwardrules">
        <tr><td align="left" colspan="7">internet_forwardrules</td></tr>
        <tr> <th bgcolor="#bae3ff">$(lang en:"Active" de:"Aktiv")</th> <th bgcolor="#bae3ff">$(lang en:"Protocol" de:"Protokoll")</th> <th bgcolor="#bae3ff">$(lang en:"Source Port" de:"Quell-Port")</th>
        <th bgcolor="#bae3ff">$(lang en:"Dest. Port" de:"Ziel-Port")</th> <th bgcolor="#bae3ff">$(lang en:"Description" de:"Beschreibung")</th> <th bgcolor="#bae3ff">$(lang en:"Configure" de:"Bearbeiten")</th> </tr>
        <tr style="display:none"><td bgcolor="#CDCDCD" width="40" align="center"><input type="checkbox" onclick='fwddisable[ (this.parentNode.parentNode.rowIndex -3)] = ! this.checked ; rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3));'></td><td><select onchange='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwdprot", this.value)'>
        <option value="icmp">icmp</option><option value="gre">gre</option><option value="tcp">tcp</option><option value="udp">udp</option>
        </select> </td><td><input type="text" size="8" title="SPort" onblur='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwdsport", this.value)'>
       </td><td><input type="text" size="8" title="DPort" onblur='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwddport", this.value)'>
        </td><td><input type="text" title="Descr" onblur='rebuild_fwdrule((this.parentNode.parentNode.rowIndex -3), "fwdname", this.value)'>
</td><td><center><input style="font-weight:bolder; color:red;" type="button" Value="X" title="delete rule" onclick='allfwdrules.splice(this.parentNode.parentNode.parentNode.rowIndex -3 ,1); fwdrulescount -= 1;Init_FWDTable()'>
        </center></td>
	</tr>
</table></p>

EOF
#rm /var/tmp/forwarding.*

echo '<script>'

if [ $FWVER -lt 555 ]; then # "alte" firmware
echo 'allfwdrules=new Array ('$(echo ar7cfg.dslifaces.dsldpconfig.forwardrules | ar7cfgctl -s)')';
else
# try for newer Firmwares with another portforwarding mechanism
echo 'allfwdrules=new Array ('$(echo ar7cfg.internet_forwardrules | ar7cfgctl -s)')';
fi
cat << EOF
fwdproto=new Array();
fwdsport=new Array();
fwddport=new Array();
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

function onlynumplus(elem){
        elem.value=elem.value.replace(/[^0-9\+]+/g,'');
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
            if (fwdname[count]=splitrules.slice(next+5).join(" ")){}else {fwdname[count]=""};
            count +=1 ;
    }
    fwdrulescount=count;
}
function build_new_fwdrule(){
 document.getElementById("div_fwddport").style.display = ( fdprot != "gre" && fdprot != "icmp" )? "inline" : "none";
 document.getElementById("div_fwdsport").style.display= ( fdprot != "gre" && fdprot != "icmp" )? "inline" : "none";

 var tmp=fdprot + " 0.0.0.0";
 if ( fdprot != "gre" && fdprot != "icmp" ){ tmp +=":"+fdsport; if (fdeport > fdsport) {tmp+="+" + ((fdeport-fdsport)+1) } };
 tmp += " 0.0.0.0";
 if ( fdprot != "gre" && fdprot != "icmp" ){tmp +=":"+fdoport+" 0";};
 if ( fdname != "" ){tmp +=" # "+fdname;};
 document.getElementById("id_new_fwdrule").value = tmp;
}

function showfwdrules(){
  document.getElementById("rules").value=allfwdrules.join("\n");
}

function rebuild_fwdrule(num, name , val){
  if (name) { tmp=name +"[" + num + "] = '" + val +"'" ; eval (tmp)}
  allfwdrules[num]= (fwddisable[num]) ? "# " : "" ;
  allfwdrules[num]+=fwdproto[num]+" 0.0.0.0";
  allfwdrules[num]+= (fwdproto[num] == "gre" || fwdproto[num] == "icmp") ? " "+"0.0.0.0" : ":"+fwdsport[num]+" 0.0.0.0:"+fwddport[num];
  allfwdrules[num] +=" 0";
  if (fwdname[num]){ allfwdrules[num] +=" # "+fwdname[num] ;}
  showfwdrules();
}
function Init_FWDTable(){
  var number=Number(fwdrulescount);
  if (number<1){alert("$(lang en:"No forwarding rules found. Please activate at least one rule." de:"Keine Regeln gefunden. Bitte mindestens eine Weiterleitung aktivieren.")"); exit;}
  var tbl = document.getElementById("id_table_forwardrules");
  var lastRow = tbl.rows.length;
  split_fwdrules() ;
  for (j=3;j<=fwdrulescount+2;j++){
  	if (j >= lastRow) {var row = tbl.insertRow(j);for (i=0; i<=5 ; i++){row.appendChild(tbl.rows[2].cells[i].cloneNode(true))}};
  	tbl.rows[j].style.display='';

        cn=tbl.rows[j].childNodes;
        var el_active=cn[0].firstChild;
        var el_prot=cn[1].firstChild;
        var el_sport=cn[2].firstChild;
        var el_dport=cn[3].firstChild;
        var el_name=cn[4].firstChild;
        var lastel=cn[5].childNodes;
        var has_no_port=(fwdproto[j-3] == "gre" || fwdproto[j-3] == "icmp");
        el_active.checked=( !fwddisable[(j-3)] ) ? true : false;
        el_prot.value=fwdproto[j-3];
        el_sport.disabled=has_no_port;
        el_sport.value=fwdsport[j-3];
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



</script>
EOF
sec_end
cat << EOF
<font size="1">$(lang en:"\"Defaults\" has no efect here (only reloads this GUI)" de:"\"Standard\" hat keine Funktion (l&auml;dt die GUI nur neu)").</font><br />
<input type="hidden" name="do_activate" value=""></font>
$(lang en:"Saving will <b>not</b> activate any rule by default! <b>To do so, some daemoms have to be restarted:</b>" de:"Die Regeln werden standardm&auml;&szlig;ig <b>nicht</b> aktiviert!  Dazu m&uuml;ssen AVM-Dienste neu gestartet werden:") <br />
<img src="/images/blink!.gif" title="Attention!" valign="center"> &nbsp; <b>$(lang en:"This might crash your box or even restore factory defaults!" de:"Das kann zum Absturz oder sogar zum Werksreset f&uuml;hren!") </b> &nbsp;&nbsp;&nbsp; $(lang en:"Activate rules directly after saving" de:"Regeln gleich nach Speichern aktivieren") <input type="checkbox" value="dsld_ctlmgr" name="do_activate" ><br />
<font size="1">($(lang en:"Safe way to activate the settings is only save them here and then restart the box" de:"Um die &Auml;nderungen \"sicher\" zu aktivieren, hier nur \"&Uuml;bernehmen\" w&auml;hlen und dann die Box neu starten"))</font><br />
EOF

