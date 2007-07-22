#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin

. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''

if [ "$NTFS_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end


sec_begin 'Devices'

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

document.write("<p><SELECT NAME='device' onChange='change(value)'>" +
"<OPTION SELECTED VALUE='0'>Device 1</OPTION>" + 
"<OPTION VALUE='1'>Device 2</OPTION>" + 
"<OPTION VALUE='2'>Device 3</OPTION>" +
"</SELECT></p>");

document.write("<div id='Acc1' style='display:block'><p><label id='acc1' for='r06'>Device: </label><input id='r06' type='text' name='device1' size='50' maxlength='255' value='$(httpd -e "$NTFS_DEVICE1")'></p>" +
"<hr color='silver'>" + 
"<p><label for='r05'>Mountpoint: </label><input id='r05' type='text' name='mountpoint1' size='50' maxlength='255' value='$(httpd -e "$NTFS_MOUNTPOINT1")'></p>" + 
"</div>");

document.write("<div id='Acc2' style='display:none'><p><label id='acc2' for='r16'>Device: </label><input id='r16' type='text' name='device2' size='50' maxlength='255' value='$(httpd -e "$NTFS_DEVICE2")'></p>" +
"<hr color='silver'>" + 
"<p><label for='r15'>Mountpoint: </label><input id='r15' type='text' name='mountpoint2' size='50' maxlength='255' value='$(httpd -e "$NTFS_MOUNTPOINT2")'></p>" + 
"</div>");

document.write("<div id='Acc3' style='display:none'><p><label id='acc3' for='r26'>Device: </label><input id='r26' type='text' name='device3' size='50' maxlength='255' value='$(httpd -e "$NTFS_DEVICE3")'></p>" +
"<hr color='silver'>" + 
"<p><label for='r25'>Mountpoint: </label><input id='r25' type='text' name='mountpoint3' size='50' maxlength='255' value='$(httpd -e "$NTFS_MOUNTPOINT3")'></p>" + 
"</div>");
</script>

EOF

sec_end
