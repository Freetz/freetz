#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$CHECKMAILD_IMAP0" Y:imap0 "*":pop0
check "$CHECKMAILD_IMAP1" Y:imap1 "*":pop1
check "$CHECKMAILD_IMAP2" Y:imap2 "*":pop2
check "$CHECKMAILD_CFGNOTIFY" Y:cfgnotify_yes "*":cfgnotify_no
check "$CHECKMAILD_RECVMSG" Y:msg_recv_yes "*":msg_recv_no

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$CHECKMAILD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konten" en:"Accounts")"

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

document.write("<div id='Account0' style='display:block'><p>" +
"<label id='Kontoname0' for='r06'>$(lang de:"Kontoname" en:"Name"): </label><input id='r06' type='text' name='user0' size='20' maxlength='255' value='$(html "$CHECKMAILD_USER0")'></p>" +
"<p>$(lang de:"Posteingangsserver" en:"Incoming mail server"):" +
"<input id='r01' type='text' name='server0' size='30' maxlength='255' value='$(html "$CHECKMAILD_SERVER0")'>" +
"<input id='e01' type='radio' name='imap0' value='Y'$imap0_chk><label for='e01'> IMAP</label>" +
"<input id='e02' type='radio' name='imap0' value='N'$pop0_chk><label for='e01'> POP3</label></p>" +
"<p><label for='r03'>$(lang de:"Benutzername" en:"Username"): </label><input id='r03' type='text' name='username0' size='30' maxlength='255' value='$(html "$CHECKMAILD_USERNAME0")'></p>" +
"<p><label for='r04'>$(lang de:"Kennwort" en:"Password"): </label><input id='r04' type='password' name='password0' size='20' maxlength='255' value='$(html "$CHECKMAILD_PASSWORD0")'></p>" +
"</div>");

document.write("<div id='Account1' style='display:none'><p>" +
"<label id='Kontoname1' for='r16'>$(lang de:"Kontoname" en:"Name"): </label><input id='r16' type='text' name='user1' size='20' maxlength='255' value='$(html "$CHECKMAILD_USER1")'></p>" +
"<p><label for='r11'>$(lang de:"Posteingangsserver" en:"Incoming mail server"): " +
"<input id='r11' type='text' name='server1' size='30' maxlength='255' value='$(html "$CHECKMAILD_SERVER1")'>" +
"<input id='e11' type='radio' name='imap1' value='Y'$imap1_chk><label for='e11'> IMAP</label>" +
"<input id='e12' type='radio' name='imap1' value='N'$pop1_chk><label for='e12'> POP3</label></p>" +
"<p><label for='r13'>$(lang de:"Benutzername" en:"Username"): </label><input id='r13' type='text' name='username1' size='30' maxlength='255' value='$(html "$CHECKMAILD_USERNAME1")'></p>" +
"<p><label for='r14'>$(lang de:"Kennwort" en:"Password"): </label><input id='r14' type='password' name='password1' size='20' maxlength='255' value='$(html "$CHECKMAILD_PASSWORD1")'></p>" +
"</div>");

document.write("<div id='Account2' style='display:none'><p>" +
"<label id='Kontoname2' for='r16'>$(lang de:"Kontoname" en:"Name"): </label><input id='r16' type='text' name='user2' size='20' maxlength='255' value='$(html "$CHECKMAILD_USER2")'></p>" +
"<p><label for='r21'>$(lang de:"Posteingangsserver" en:"Incoming mail server"): </p>" +
"<input id='r21' type='text' name='server2' size='30' maxlength='255' value='$(html "$CHECKMAILD_SERVER2")'>" +
"<input id='e21' type='radio' name='imap2' value='Y'$imap2_chk><label for='e21'> IMAP</label>" +
"<input id='e22' type='radio' name='imap2' value='N'$pop2_chk><label for='e22'> POP3</label></p>" +
"<p><label for='r23'>$(lang de:"Benutzername" en:"Username"): </label><input id='r23' type='text' name='username2' size='30' maxlength='255' value='$(html "$CHECKMAILD_USERNAME2")'></p>" +
"<p><label for='r24'>$(lang de:"Kennwort" en:"Password"): </label><input id='r24' type='password' name='password2' size='20' maxlength='255' value='$(html "$CHECKMAILD_PASSWORD2")'></p>" +
"</div>");
</script>
EOF

sec_end

sec_begin "$(lang de:"Einstellungen" en:"Configuration")"

cat << EOF
<input type='hidden' name='cfgnotify' value='N'>
<input type='hidden' name='recvmsg' value='N'>
<p><label for='r31'>$(lang de:"Postfach alle" en:"Check mailbox every")</label>
<input id='r31' type='text' name='intervall' size='3' maxlength='255' value='$(html "$CHECKMAILD_INTERVALL")'> $(lang de:"Minuten auf neue Mails &uuml;berpr&uuml;fen" en:"minutes")</p>
<p><label for='r34'>$(lang de:"Skriptaufruf einschalten" en:"Enable script execution")  </label><input id='r34' type='checkbox' name='cfgnotify' value='Y'$cfgnotify_yes_chk></p>
<p><label for='r35'>$(lang de:"Header und Body empfangen" en:"Download header and body") </label><input id='r35' type='checkbox' name='recvmsg' value='Y'$msg_recv_yes_chk></p>
EOF

sec_end

