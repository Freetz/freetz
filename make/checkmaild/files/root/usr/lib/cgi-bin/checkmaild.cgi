#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin

. /usr/lib/libmodcgi.sh

check "$CHECKMAILD_ENABLED" yes:auto "*":man
check "$CHECKMAILD_TELNOT" Y:tel_not
check "$CHECKMAILD_LEDNOTIFY" Y:led_not
check "$CHECKMAILD_CFGNOTIFY" Y:cfg_not
check "$CHECKMAILD_RECVMSG" Y:msg_recv

select "$CHECKMAILD_LEDMAJOR" 1:pow 2:dsl 3:lan 4:wlan 7:info 13:fest \
	14:int "*":info

select "$CHECKMAILD_LEDMINOR" 2:alw 3:fast 4:slow "*":alw

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end

sec_begin '$(lang de:"Konten" en:"Accounts")'

cat << EOF
<script>
function change(value) {
	document.getElementById("Account0").style.display = "none";
	document.getElementById("Account1").style.display = "none";
	document.getElementById("Account2").style.display = "none";
	
	switch (value) {
		case "0":
			document.getElementById("Account0").style.display = "block";
			break;
		case "1":
			document.getElementById("Account1").style.display = "block";
			break;
		case "2":
			document.getElementById("Account2").style.display = "block";
			break;
		}

}

document.write("<p><SELECT NAME='acount' onChange='change(value)'>" +
"<OPTION SELECTED VALUE='0'>Account 0</OPTION>" + 
"<OPTION VALUE='1'>Account 1</OPTION>" + 
"<OPTION VALUE='2'>Account 2</OPTION>" +
"</SELECT></p>");

document.write("<div id='Account0' style='display:block'><p><label id='Kontoname0' for='r06'>$(lang de:"Kontoname" en:"Name"): </label><input id='r06' type='text' name='user0' size='20' maxlength='255' value='$(html "$CHECKMAILD_USER0")'></p>" +
"<p>$(lang de:"Posteingangsserver" en:"Incoming mail server"): </p>" +
"<p><label for='r01'>$(lang de:"POP3-Server" en:"POP3 Server"): </label><input id='r01' type='text' name='popserver0' size='20' maxlength='255' value='$(html "$CHECKMAILD_POPSERVER0")'>" +
"<label for='r02'> $(lang de:"IMAP-Server" en:"IMAP Server"): </label><input id='r02' type='text' name='imapserver0' size='20' maxlength='255' value='$(html "$CHECKMAILD_IMAPSERVER0")'></p>" +
"<p><label for='r03'>$(lang de:"Benutzername" en:"Username"): </label><input id='r03' type='text' name='username0' size='30' maxlength='255' value='$(html "$CHECKMAILD_USERNAME0")'></p>" +
"<p><label for='r04'>$(lang de:"Kennwort" en:"Password"): </label><input id='r04' type='password' name='password0' size='20' maxlength='255' value='$(html "$CHECKMAILD_PASSWORD0")'></p>" + 
"</div>");

document.write("<div id='Account1' style='display:none'><p><label id='Kontoname1' for='r16'>$(lang de:"Kontoname" en:"Name"): </label><input id='r16' type='text' name='user1' size='20' maxlength='255' value='$(html "$CHECKMAILD_USER1")'></p>" +
"<p>$(lang de:"Posteingangsserver" en:"Incoming mail server"): </p>" +
"<p><label for='r11'>$(lang de:"POP3-Server" en:"POP3 Server"): </label><input id='r11' type='text' name='popserver1' size='20' maxlength='255' value='$(html "$CHECKMAILD_POPSERVER1")'>" +
"<label for='r12'> $(lang de:"IMAP-Server" en:"IMAP Server"): </label><input id='r12' type='text' name='imapserver1' size='20' maxlength='255' value='$(html "$CHECKMAILD_IMAPSERVER1")'></p>" +
"<p><label for='r13'>$(lang de:"Benutzername" en:"Username"): </label><input id='r13' type='text' name='username1' size='30' maxlength='255' value='$(html "$CHECKMAILD_USERNAME1")'></p>" +
"<p><label for='r14'>$(lang de:"Kennwort" en:"Password"): </label><input id='r14' type='password' name='password1' size='20' maxlength='255' value='$(html "$CHECKMAILD_PASSWORD1")'></p>" + 
"</div>");

document.write("<div id='Account2' style='display:none'><p><label id='Kontoname2' for='r16'>$(lang de:"Kontoname" en:"Name"): </label><input id='r16' type='text' name='user2' size='20' maxlength='255' value='$(html "$CHECKMAILD_USER2")'></p>" +
"<p>$(lang de:"Posteingangsserver" en:"Incoming mail server"): </p>" +
"<p><label for='r21'>$(lang de:"POP3-Server" en:"POP3 Server"): </label><input id='r21' type='text' name='popserver2' size='20' maxlength='255' value='$(html "$CHECKMAILD_POPSERVER2")'>" +
"<label for='r22'> $(lang de:"IMAP-Server" en:"IMAP Server"): </label><input id='r22' type='text' name='imapserver2' size='20' maxlength='255' value='$(html "$CHECKMAILD_IMAPSERVER2")'></p>" +
"<p><label for='r23'>$(lang de:"Benutzername" en:"Username"): </label><input id='r23' type='text' name='username2' size='30' maxlength='255' value='$(html "$CHECKMAILD_USERNAME2")'></p>" +
"<p><label for='r24'>$(lang de:"Kennwort" en:"Password"): </label><input id='r24' type='password' name='password2' size='20' maxlength='255' value='$(html "$CHECKMAILD_PASSWORD2")'></p>" +
"</div>");
</script>
EOF

sec_end

sec_begin '$(lang de:"Einstellungen" en:"Configuration")'

cat << EOF
<input type='hidden' name='lednotify' value='N'>
<p><label for='r31'>$(lang de:"Postfach alle" en:"Check mailbox every")  </label><input id='r31' type='text' name='intervall' size='3' maxlength='255' value='$(html "$CHECKMAILD_INTERVALL")'> $(lang de:"Minuten auf neue Mails &uuml;berpr&uuml;fen" en:"minutes")</p>
<p><label for='r32'>$(lang de:"Signalisierung" en:"Notification by"): </label> <input id='r32' type='checkbox' name='lednotify' value='Y'$led_not_chk>
<SELECT ID='r32' NAME='ledmajor'>
<OPTION VALUE='1'$pow_sel>Power-LED</OPTION>
<OPTION VALUE='2'$dsl_sel>DSL-LED</OPTION>
<OPTION VALUE='3'$lan_sel>LAN-LED</OPTION>
<OPTION VALUE='4'$wlan_sel>WLAN-LED</OPTION>
<OPTION VALUE='7'$info_sel>Info-LED</OPTION>
<OPTION VALUE='13'$fest_sel>$(lang de:"Festnetz-LED" en:"Fixed Line-LED")</OPTION>
<OPTION VALUE='14'$int_sel>Internet-LED</OPTION></SELECT>
<SELECT ID='r33' NAME='ledminor'>
<OPTION VALUE='2'$always_sel>$(lang de:"immer an" en:"Always on")</OPTION>
<OPTION VALUE='3'$fast_sel>$(lang de:"schnelles blinken" en:"Fast blinking")</OPTION>
<OPTION VALUE='4'$slow_sel>$(lang de:"langsames blinken" en:"Slow blinking")</OPTION></SELECT>
</p> 
EOF

sec_end

sec_begin '$(lang de:"Telefonbenachrichtigung" en:"Telephone notification")'

cat << EOF
<input type='hidden' name='telnot' value='N'>
<p><label for='r7'>$(lang de:"Telefonbenachrichtigung einschalten" en:"Enable telephone notification")  </label><input id='r7' type='checkbox' name='telnot' value='Y'$tel_not_chk></p>
<p><label for='r8'>$(lang de:"Sip-Account" en:"Sip account"):  </label><input id='r8' type='text' name='sipaccount' size='3' maxlength='3' value='$(html "$CHECKMAILD_SIPACCOUNT")'></p>
<p><label for='r9'>$(lang de:"Telefonnummer" en:"Telephone number"): </label><input id='r9' type='text' name='phonenumber' size='15' maxlength='15' value='$(html "$CHECKMAILD_PHONENUMBER")'></p>
<p><label for='r9'>$(lang de:"Nebenstellen-Nummer" en:"Substation"): </label><input id='r9' type='text' name='substation' size='1' maxlength='2' value='$(html "$CHECKMAILD_SUBSTATION")'></p>

EOF

sec_end

sec_begin '$(lang de:"Skript" en:"Script")'

cat << EOF
<input type='hidden' name='cfgnotify' value='N'>
<input type='hidden' name='recvmsg' value='N'>
<p><label for='r34'>$(lang de:"Skriptaufruf einschalten" en:"Enable script execution")  </label><input id='r34' type='checkbox' name='cfgnotify' value='Y'$cfg_not_chk> (/mod/etc/maillog.cfg)</p>
<p><label for='r35'>$(lang de:"Header und Body empfangen" en:"Download header and body") </label><input id='r35' type='checkbox' name='recvmsg' value='Y'$msg_recv_chk></p>
EOF

sec_end
