#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin

. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''

if [ "$CHECKMAILD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

tel_not=''
if [ "$CHECKMAILD_TELNOT" = "Y" ]; then tel_not=' checked'; fi

led_not=''
if [ "$CHECKMAILD_LEDNOTIFY" = "Y" ]; then led_not=' checked'; fi

cfg_not=''
if [ "$CHECKMAILD_CFGNOTIFY" = "Y" ]; then cfg_not=' checked'; fi

msg_recv=''
if [ "$CHECKMAILD_RECVMSG" = "Y" ]; then msg_recv=' checked'; fi


pow_sel=''; dsl_sel=''; lan_sel=''; wlan_sel=''; info_sel=''; fest_sel=''; int_sel=''; always_sel=''; slow_sel=''; fast_sel=''

case "$CHECKMAILD_LEDMAJOR" in
1)
pow_sel=' selected'
;;
2)
dsl_sel=' selected'
;;
3) 
lan_sel=' selected'
;;
4) 
wlan_sel=' selected'
;; 
7) 
info_sel=' selected'
;;
13) 
fest_sel=' selected'
;;
14) 
int_sel=' selected'
;;
*) 
info_sel=' selected'
;;
esac

case $CHECKMAILD_LEDMINOR in
2) 
alw_sel=' selected'
;;
3) 
fast_sel=' selected'
;;
4) 
slow_sel=' selected'
;;
*) 
alw_sel=' selected'
;;
esac

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end

sec_begin 'Konten'

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

document.write("<div id='Account0' style='display:block'><p><label id='Kontoname0' for='r06'>Kontoname: </label><input id='r06' type='text' name='user0' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_USER0")'></p>" +
"<p>Posteingangsserver: </p>" +
"<p><label for='r01'>POP3-Server: </label><input id='r01' type='text' name='popserver0' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_POPSERVER0")'>" +
"<label for='r02'> IMAP-Server: </label><input id='r02' type='text' name='imapserver0' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_IMAPSERVER0")'></p>" +
"<p><label for='r03'>Benutzername: </label><input id='r03' type='text' name='username0' size='30' maxlength='255' value='$(httpd -e "$CHECKMAILD_USERNAME0")'></p>" +
"<p><label for='r04'>Kennwort: </label><input id='r04' type='password' name='password0' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_PASSWORD0")'></p>" + 
"</div>");

document.write("<div id='Account1' style='display:none'><p><label id='Kontoname1' for='r16'>Kontoname: </label><input id='r16' type='text' name='user1' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_USER1")'></p>" +
"<p>Posteingangsserver: </p>" +
"<p><label for='r11'>POP3-Server: </label><input id='r11' type='text' name='popserver1' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_POPSERVER1")'>" +
"<label for='r12'> IMAP-Server: </label><input id='r12' type='text' name='imapserver1' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_IMAPSERVER1")'></p>" +
"<p><label for='r13'>Benutzername: </label><input id='r13' type='text' name='username1' size='30' maxlength='255' value='$(httpd -e "$CHECKMAILD_USERNAME1")'></p>" +
"<p><label for='r14'>Kennwort: </label><input id='r14' type='password' name='password1' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_PASSWORD1")'></p>" + 
"</div>");

document.write("<div id='Account2' style='display:none'><p><label id='Kontoname2' for='r16'>Kontoname: </label><input id='r16' type='text' name='user2' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_USER2")'></p>" +
"<p>Posteingangsserver: </p>" +
"<p><label for='r21'>POP3-Server: </label><input id='r21' type='text' name='popserver2' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_POPSERVER2")'>" +
"<label for='r22'> IMAP-Server: </label><input id='r22' type='text' name='imapserver2' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_IMAPSERVER2")'></p>" +
"<p><label for='r23'>Benutzername: </label><input id='r23' type='text' name='username2' size='30' maxlength='255' value='$(httpd -e "$CHECKMAILD_USERNAME2")'></p>" +
"<p><label for='r24'>Kennwort: </label><input id='r24' type='password' name='password2' size='20' maxlength='255' value='$(httpd -e "$CHECKMAILD_PASSWORD2")'></p>" +
"</div>");
</script>
EOF

sec_end

sec_begin 'Einstellungen'

cat << EOF
<input type='hidden' name='lednotify' value='N'>
<p><label for='r31'>Postfach alle  </label><input id='r31' type='text' name='intervall' size='3' maxlength='255' value='$(httpd -e "$CHECKMAILD_INTERVALL")'> Minuten auf neue Mails &uuml;berpr&uuml;fen</p>
<p><label for='r32'>Signalisierung: </label> <input id='r32' type='checkbox' name='lednotify' value='Y'$led_not>
<SELECT ID='r32' NAME='ledmajor'>
<OPTION VALUE='1'$pow_sel>Power-LED</OPTION>
<OPTION VALUE='2'$dsl_sel>DSL-LED</OPTION>
<OPTION VALUE='3'$lan_sel>LAN-LED</OPTION>
<OPTION VALUE='4'$wlan_sel>WLAN-LED</OPTION>
<OPTION VALUE='7'$info_sel>Info-LED</OPTION>
<OPTION VALUE='13'$fest_sel>Festnetz-LED</OPTION>
<OPTION VALUE='14'$int_sel>Internet-LED</OPTION></SELECT>
<SELECT ID='r33' NAME='ledminor'>
<OPTION VALUE='2'$always_sel>immer an</OPTION>
<OPTION VALUE='3'$fast_sel>schnelles blinken</OPTION>
<OPTION VALUE='4'$slow_sel>langsames blinken</OPTION></SELECT>
</p> 
EOF

sec_end

sec_begin 'Telefonbenachrichtigung'

cat << EOF
<input type='hidden' name='telnot' value='N'>
<p><label for='r7'>Telefonbenachrichtigung einschalten  </label><input id='r7' type='checkbox' name='telnot' value='Y'$tel_not></p>
<p><label for='r8'>Sip-Account:  </label><input id='r8' type='text' name='sipaccount' size='3' maxlength='3' value='$(httpd -e "$CHECKMAILD_SIPACCOUNT")'></p>
<p><label for='r9'>Telefonnummer: </label><input id='r9' type='text' name='phonenumber' size='15' maxlength='15' value='$(httpd -e "$CHECKMAILD_PHONENUMBER")'></p>
<p><label for='r9'>Nebenstellen-Nummer: </label><input id='r9' type='text' name='substation' size='1' maxlength='2' value='$(httpd -e "$CHECKMAILD_SUBSTATION")'></p>

EOF

sec_end

sec_begin 'Skript'

cat << EOF
<input type='hidden' name='cfgnotify' value='N'>
<input type='hidden' name='recvmsg' value='N'>
<p><label for='r34'>Skriptaufruf einschalten  </label><input id='r34' type='checkbox' name='cfgnotify' value='Y'$cfg_not> (/mod/etc/maillog.cfg)</p>
<p><label for='r35'>Header und Body empfangen </label><input id='r35' type='checkbox' name='recvmsg' value='Y'$msg_recv></p>
EOF

sec_end
