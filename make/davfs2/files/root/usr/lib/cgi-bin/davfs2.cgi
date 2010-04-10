#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin

. /usr/lib/libmodcgi.sh

check "$DAVFS2_ENABLED" yes:auto "*":man


sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end


sec_begin '$(lang de:"Temp-Pfad" en:"Temp path")'

cat << EOF
<p>
<input id="e3" type="text" name="tmppath" value='$(html "$DAVFS2_TMPPATH")'>
</p>
EOF

sec_end

sec_begin '$(lang de:"Konten" en:"Accounts")'

cat << EOF
 
<script>
function change(value) {
	document.getElementById("Acc1").style.display = "none";
	document.getElementById("Acc2").style.display = "none";
	document.getElementById("Acc3").style.display = "none";
	
	switch (value) {
		case "0":
			document.getElementById("Acc1").style.display = "block";
			break;
		case "1":
			document.getElementById("Acc2").style.display = "block";
			break;
		case "2":
			document.getElementById("Acc3").style.display = "block";
			break;
		}

}

document.write("<p><SELECT NAME='account' onChange='change(value)'>" +
"<OPTION SELECTED VALUE='0'>WebDAV Account 1</OPTION>" + 
"<OPTION VALUE='1'>WebDAV Account 2</OPTION>" + 
"<OPTION VALUE='2'>WebDAV Account 3</OPTION>" +
"</SELECT></p>");

document.write("<div id='Acc1' style='display:block'><p><label id='acc1' for='r06'>Host: </label><input id='r06' type='text' name='host1' size='50' maxlength='255' value='$(html "$DAVFS2_HOST1")'></p>" +
"<p>$(lang en:"Use certificate for server (see 'Settings' in GUI)" de:"Zertifikat f&uuml;r Server nutzen (siehe Punkt 'Einstellungen')")"+  
"<input type='hidden' name='servercert1' value=''><input type='checkbox' name='servercert1' value='yes' $([ "$DAVFS2_SERVERCERT1" = yes ] && echo checked)> </p>" + 
"<p><label for='r03'>User: </label><input id='r03' type='text' name='user1' size='50' maxlength='255' value='$(html "$DAVFS2_USER1")'></p>" +
"<p><label for='r04'>Pass: </label><input id='r04' type='password' name='pass1' size='50' maxlength='255' value='$(html "$DAVFS2_PASS1")'></p>" + 
"<hr color='silver'>" + 
"<p><label for='r05'>Mountpoint: </label><input id='r05' type='text' name='mountpoint1' size='50' maxlength='255' value='$(html "$DAVFS2_MOUNTPOINT1")'></p>" + 
"</div>");

document.write("<div id='Acc2' style='display:none'><p><label id='acc2' for='r16'>Host: </label><input id='r16' type='text' name='host2' size='50' maxlength='255' value='$(html "$DAVFS2_HOST2")'></p>" +
"<p>$(lang en:"Use certificate for server (see 'Settings' in GUI)" de:"Zertifikat f&uuml;r Server nutzen (siehe Punkt 'Einstellungen')")"+  
"<input type='hidden' name='servercert2' value=''><input type='checkbox' name='servercert2' value='yes' $([ "$DAVFS2_SERVERCERT2" = yes ] && echo checked)> </p>" + 
"<p><label for='r13'>User: </label><input id='r13' type='text' name='user2' size='50' maxlength='255' value='$(html "$DAVFS2_USER2")'></p>" +
"<p><label for='r14'>Pass: </label><input id='r14' type='password' name='pass2' size='50' maxlength='255' value='$(html "$DAVFS2_PASS2")'></p>" + 
"<hr color='silver'>" + 
"<p><label for='r15'>Mountpoint: </label><input id='r15' type='text' name='mountpoint2' size='50' maxlength='255' value='$(html "$DAVFS2_MOUNTPOINT2")'></p>" + 
"</div>");

document.write("<div id='Acc3' style='display:none'><p><label id='acc3' for='r26'>Host: </label><input id='r26' type='text' name='host3' size='50' maxlength='255' value='$(html "$DAVFS2_HOST3")'></p>" +
"<p>$(lang en:"Use certificate for server (see 'Settings' in GUI)" de:"Zertifikat f&uuml;r Server nutzen (siehe Punkt 'Einstellungen')")"+  
"<input type='hidden' name='servercert3' value=''><input type='checkbox' name='servercert3' value='yes' $([ "$DAVFS2_SERVERCERT3" = yes ] && echo checked)> </p>" + 
"<p><label for='r23'>User: </label><input id='r23' type='text' name='user3' size='50' maxlength='255' value='$(html "$DAVFS2_USER3")'></p>" +
"<p><label for='r24'>Pass: </label><input id='r24' type='password' name='pass3' size='50' maxlength='255' value='$(html "$DAVFS2_PASS3")'></p>" + 
"<hr color='silver'>" + 
"<p><label for='r25'>Mountpoint: </label><input id='r25' type='text' name='mountpoint3' size='50' maxlength='255' value='$(html "$DAVFS2_MOUNTPOINT3")'></p>" + 
"</div>");
</script>

EOF

sec_end

