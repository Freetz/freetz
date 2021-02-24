#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg


sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$DAVFS2_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Einstellungen" en:"Settings")"
cat << EOF
<p>
$(lang de:"Tempor&auml;res Verzeichnis" en:"Temporary directory")
<input id="e3" type="text" name="tmppath" value='$(html "$DAVFS2_TMPPATH")'><br>
<font size=-2>$(lang de:"Hinweis: Um gr&ouml;&szlig;ere Dateien zu kopieren, das Verzeichnis auf einen USB-Stick legen und sicherstellen, da&szlig; dieser nicht entfernt wird (oder external-services nutzen)." en:"Hint: Use a USB-device for larger files but don't remove it (or use external-services).")</font>
</p>
<p>
$(lang de:"Cachegr&ouml;&szlig;e" en:"Cache size")
<input id="e4" type="text" size='5' maxlength='5' name="cache_size" value='$(html "$DAVFS2_CACHE_SIZE")'><br>
<font size=-2>$(lang de:"Vorsicht: Es wird ledigleich eine Warnung bei &Uuml;berchreitung der Cashegr&ouml;&szlig;e ausgegeben." en:"Attention: Only a warning is been showing on overrunning the limitation.")</font>
</p>
EOF
sec_end

sec_begin "$(lang de:"Konten" en:"Accounts")"
cat << EOF
<script>

function change(value) {
	document.getElementById("Acc1").style.display = "none";
	document.getElementById("Acc2").style.display = "none";
	document.getElementById("Acc3").style.display = "none";

	switch (value) {
		case "1":
			document.getElementById("Acc1").style.display = "block";
			break;
		case "2":
			document.getElementById("Acc2").style.display = "block";
			break;
		case "3":
			document.getElementById("Acc3").style.display = "block";
			break;
		}
}

document.write("<p><SELECT NAME='account' onChange='change(value)'>" +
"<OPTION SELECTED VALUE='1'>$(lang de:"Konto" en:"Account") 1</OPTION>" +
"<OPTION          VALUE='2'>$(lang de:"Konto" en:"Account") 2</OPTION>" +
"<OPTION          VALUE='3'>$(lang de:"Konto" en:"Account") 3</OPTION>" +
"</SELECT></p>");

document.write("<div id='Acc1' style='display:block'>" +
"<p><input type='hidden' name='enabled1' value=''><input type='checkbox' name='enabled1' value='yes' $([ "$DAVFS2_ENABLED1" = yes ] && echo checked)>$(lang en:"Account enabled" de:"Konto aktiv")</p>" +
"<p><label id='acc1' for='r16'>Host: </label><input id='r16' type='text' name='host1' size='50' maxlength='255' value='$(html "$DAVFS2_HOST1")'></p>" +
"<p><input type='hidden' name='servercert1' value=''><input type='checkbox' name='servercert1' value='yes' $([ "$FREETZ_PACKAGE_DAVFS2_WITH_SSL" != "y" ] && echo DISABLED || ([ "$DAVFS2_SERVERCERT1" = yes ] && echo checked))>$(lang en:"Use certificate 1" de:"Zertifikat 1 nutzen")</p>" +
"<p><label for='r13'>$(lang en:"Username" de:"Benutzername"): </label><input id='r13' type='text' name='user1' size='50' maxlength='255' value='$(html "$DAVFS2_USER1")'></p>" +
"<p><label for='r14'>$(lang en:"Password" de:"Passwort"): </label><input id='r14' type='password' name='pass1' size='50' maxlength='255' value='$(html "$DAVFS2_PASS1")'></p>" +
"<p><input type='hidden' name='uselocks1' value=''><input type='checkbox' name='uselocks1' value='yes' $([ "$DAVFS2_USELOCKS1" = yes ] && echo checked)>$(lang en:"Deactivate use-locks" de:"Deaktiviere use-locks")</p>" +
"<p><input type='hidden' name='ifmatchbug1' value=''><input type='checkbox' name='ifmatchbug1' value='yes' $([ "$DAVFS2_IFMATCHBUG1" = yes ] && echo checked)>$(lang en:"Activate if_match_bug-option" de:"Aktiviere if_match_bug-Option")</p>" +
"<p><label for='r15'>$(lang en:"Mountpoint" de:"Einh&auml;ngepunkt"): </label><input id='r15' type='text' name='mountpoint1' size='50' maxlength='255' value='$(html "$DAVFS2_MOUNTPOINT1")'></p>" +
"</div>");

document.write("<div id='Acc2' style='display:none'>" +
"<p><input type='hidden' name='enabled2' value=''><input type='checkbox' name='enabled2' value='yes' $([ "$DAVFS2_ENABLED2" = yes ] && echo checked)>$(lang en:"Account enabled" de:"Konto aktiv")</p>" +
"<p><label id='acc2' for='r26'>Host: </label><input id='r26' type='text' name='host2' size='50' maxlength='255' value='$(html "$DAVFS2_HOST2")'></p>" +
"<p><input type='hidden' name='servercert2' value=''><input type='checkbox' name='servercert2' value='yes' $([ "$FREETZ_PACKAGE_DAVFS2_WITH_SSL" != "y" ] && echo DISABLED || ([ "$DAVFS2_SERVERCERT2" = yes ] && echo checked))>$(lang en:"Use certificate 2" de:"Zertifikat 2 nutzen")</p>" +
"<p><label for='r23'>$(lang en:"Username" de:"Benutzername"): </label><input id='r23' type='text' name='user2' size='50' maxlength='255' value='$(html "$DAVFS2_USER2")'></p>" +
"<p><label for='r24'>$(lang en:"Password" de:"Passwort"): </label><input id='r24' type='password' name='pass2' size='50' maxlength='255' value='$(html "$DAVFS2_PASS2")'></p>" +
"<p><input type='hidden' name='uselocks2' value=''><input type='checkbox' name='uselocks2' value='yes' $([ "$DAVFS2_USELOCKS2" = yes ] && echo checked)>$(lang en:"Deactivate use-locks" de:"Deaktiviere use-locks")</p>" +
"<p><input type='hidden' name='ifmatchbug2' value=''><input type='checkbox' name='ifmatchbug2' value='yes' $([ "$DAVFS2_IFMATCHBUG2" = yes ] && echo checked)>$(lang en:"Activate if_match_bug-option" de:"Aktiviere if_match_bug-Option")</p>" +
"<p><label for='r25'>$(lang en:"Mountpoint" de:"Einh&auml;ngepunkt"): </label><input id='r25' type='text' name='mountpoint2' size='50' maxlength='255' value='$(html "$DAVFS2_MOUNTPOINT2")'></p>" +
"</div>");

document.write("<div id='Acc3' style='display:none'>" +
"<p><input type='hidden' name='enabled3' value=''><input type='checkbox' name='enabled3' value='yes' $([ "$DAVFS2_ENABLED3" = yes ] && echo checked)>$(lang en:"Account enabled" de:"Konto aktiv")</p>" +
"<p><label id='acc3' for='r36'>Host: </label><input id='r36' type='text' name='host3' size='50' maxlength='255' value='$(html "$DAVFS2_HOST3")'></p>" +
"<p><input type='hidden' name='servercert3' value=''><input type='checkbox' name='servercert3' value='yes' $([ "$FREETZ_PACKAGE_DAVFS2_WITH_SSL" != "y" ] && echo DISABLED || ([ "$DAVFS2_SERVERCERT3" = yes ] && echo checked))>$(lang en:"Use certificate 3" de:"Zertifikat 3 nutzen")</p>" +
"<p><label for='r33'>$(lang en:"Username" de:"Benutzername"): </label><input id='r33' type='text' name='user3' size='50' maxlength='255' value='$(html "$DAVFS2_USER3")'></p>" +
"<p><label for='r34'>$(lang en:"Password" de:"Passwort"): </label><input id='r34' type='password' name='pass3' size='50' maxlength='255' value='$(html "$DAVFS2_PASS3")'></p>" +
"<p><input type='hidden' name='uselocks3' value=''><input type='checkbox' name='uselocks3' value='yes' $([ "$DAVFS2_USELOCKS3" = yes ] && echo checked)>$(lang en:"Deactivate use-locks" de:"Deaktiviere use-locks")</p>" +
"<p><input type='hidden' name='ifmatchbug3' value=''><input type='checkbox' name='ifmatchbug3' value='yes' $([ "$DAVFS2_IFMATCHBUG3" = yes ] && echo checked)>$(lang en:"Activate if_match_bug-option" de:"Aktiviere if_match_bug-Option")</p>" +
"<p><label for='r35'>$(lang en:"Mountpoint" de:"Einh&auml;ngepunkt"): </label><input id='r35' type='text' name='mountpoint3' size='50' maxlength='255' value='$(html "$DAVFS2_MOUNTPOINT3")'></p>" +
"</div>");

</script>
EOF
sec_end
