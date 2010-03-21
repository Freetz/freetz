#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin

. /usr/lib/libmodcgi.sh

check "$CIFSMOUNT_ENABLED" yes:auto "*":man

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end

sec_begin 'Shares'

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
"<OPTION SELECTED VALUE='0'>Share 1</OPTION>" +
"<OPTION VALUE='1'>Share 2</OPTION>" +
"<OPTION VALUE='2'>Share 3</OPTION>" +
"</SELECT></p>");

document.write("<div id='Acc1' style='display:block'><p><label id='acc1' for='r06'>Share: </label><input id='r06' type='text' name='share1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE1")'></p>" +
"<p><label for='r03'>User: </label><input id='r03' type='text' name='user1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER1")'></p>" +
"<p><label for='r04'>Pass: </label><input id='r04' type='password' name='pass1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS1")'></p>" +
"<hr color='silver'>" +
"<p><label for='r05'>Mountpoint: </label><input id='r05' type='text' name='mountpoint1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT1")'></p>" +
"</div>");

document.write("<div id='Acc2' style='display:none'><p><label id='acc2' for='r16'>Share: </label><input id='r16' type='text' name='share2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE2")'></p>" +
"<p><label for='r13'>User: </label><input id='r13' type='text' name='user2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER2")'></p>" +
"<p><label for='r14'>Pass: </label><input id='r14' type='password' name='pass2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS2")'></p>" +
"<hr color='silver'>" +
"<p><label for='r15'>Mountpoint: </label><input id='r15' type='text' name='mountpoint2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT2")'></p>" +
"</div>");

document.write("<div id='Acc3' style='display:none'><p><label id='acc3' for='r26'>Share: </label><input id='r26' type='text' name='share3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE3")'></p>" +
"<p><label for='r23'>User: </label><input id='r23' type='text' name='user3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER3")'></p>" +
"<p><label for='r24'>Pass: </label><input id='r24' type='password' name='pass3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS3")'></p>" +
"<hr color='silver'>" +
"<p><label for='r25'>Mountpoint: </label><input id='r25' type='text' name='mountpoint3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT3")'></p>" +
"</div>");
</script>

EOF

sec_end
