#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin 'Starttyp'

cgi_print_radiogroup_service_starttype "enabled" "$CIFSMOUNT_ENABLED" "" "" 0

sec_end

sec_begin 'Shares'

cat << EOF

<script>
function change(value) {
  document.getElementById("Acc1").style.display = "none";
  document.getElementById("Acc2").style.display = "none";
  document.getElementById("Acc3").style.display = "none";
  document.getElementById("Acc4").style.display = "none";
  document.getElementById("Acc5").style.display = "none";

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
    case "3":
      document.getElementById("Acc4").style.display = "block";
      break;
    case "4":
      document.getElementById("Acc5").style.display = "block";
      break;
    }

}

document.write("<p><SELECT NAME='account' onChange='change(value)'>" +
"<OPTION SELECTED VALUE='0'>Share 1</OPTION>" +
"<OPTION VALUE='1'>Share 2</OPTION>" +
"<OPTION VALUE='2'>Share 3</OPTION>" +
"<OPTION VALUE='3'>Share 4</OPTION>" +
"<OPTION VALUE='4'>Share 5</OPTION>" +
"</SELECT></p>");

document.write("<div id='Acc1' style='display:block'><p><label id='acc1' for='r06'>Share: </label><input id='r06' type='text' name='share1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE1")'></p>" +
"<p><label for='r03'>User: </label><input id='r03' type='text' name='user1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER1")'></p>" +
"<p><label for='r04'>Pass: </label><input id='r04' type='password' name='pass1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS1")'></p>" +
"<hr color='silver'>" +
"<p><label for='r07'>Mountoptions: </label><input id='r07' type='text' name='mountoptions1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTOPTIONS1")'></p>" +
"<p><label for='r05'>Mountpoint: </label><input id='r05' type='text' name='mountpoint1' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT1")'></p>" +
"</div>");

document.write("<div id='Acc2' style='display:none'><p><label id='acc2' for='r16'>Share: </label><input id='r16' type='text' name='share2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE2")'></p>" +
"<p><label for='r13'>User: </label><input id='r13' type='text' name='user2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER2")'></p>" +
"<p><label for='r14'>Pass: </label><input id='r14' type='password' name='pass2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS2")'></p>" +
"<hr color='silver'>" +
"<p><label for='r17'>Mountoptions: </label><input id='r17' type='text' name='mountoptions2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTOPTIONS2")'></p>" +
"<p><label for='r15'>Mountpoint: </label><input id='r15' type='text' name='mountpoint2' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT2")'></p>" +
"</div>");

document.write("<div id='Acc3' style='display:none'><p><label id='acc3' for='r26'>Share: </label><input id='r26' type='text' name='share3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE3")'></p>" +
"<p><label for='r23'>User: </label><input id='r23' type='text' name='user3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER3")'></p>" +
"<p><label for='r24'>Pass: </label><input id='r24' type='password' name='pass3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS3")'></p>" +
"<hr color='silver'>" +
"<p><label for='r27'>Mountoptions: </label><input id='r27' type='text' name='mountoptions3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTOPTIONS3")'></p>" +
"<p><label for='r25'>Mountpoint: </label><input id='r25' type='text' name='mountpoint3' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT3")'></p>" +
"</div>");

document.write("<div id='Acc4' style='display:none'><p><label id='acc4' for='r36'>Share: </label><input id='r36' type='text' name='share4' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE4")'></p>" +
"<p><label for='r33'>User: </label><input id='r33' type='text' name='user4' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER4")'></p>" +
"<p><label for='r34'>Pass: </label><input id='r34' type='password' name='pass4' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS4")'></p>" +
"<hr color='silver'>" +
"<p><label for='r37'>Mountoptions: </label><input id='r37' type='text' name='mountoptions4' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTOPTIONS4")'></p>" +
"<p><label for='r35'>Mountpoint: </label><input id='r35' type='text' name='mountpoint4' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT4")'></p>" +
"</div>");

document.write("<div id='Acc5' style='display:none'><p><label id='acc5' for='r46'>Share: </label><input id='r46' type='text' name='share5' size='50' maxlength='255' value='$(html "$CIFSMOUNT_SHARE5")'></p>" +
"<p><label for='r43'>User: </label><input id='r43' type='text' name='user5' size='50' maxlength='255' value='$(html "$CIFSMOUNT_USER5")'></p>" +
"<p><label for='r44'>Pass: </label><input id='r44' type='password' name='pass5' size='50' maxlength='255' value='$(html "$CIFSMOUNT_PASS5")'></p>" +
"<hr color='silver'>" +
"<p><label for='r47'>Mountoptions: </label><input id='r47' type='text' name='mountoptions5' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTOPTIONS5")'></p>" +
"<p><label for='r45'>Mountpoint: </label><input id='r45' type='text' name='mountpoint5' size='50' maxlength='255' value='$(html "$CIFSMOUNT_MOUNTPOINT5")'></p>" +
"</div>");
</script>

EOF

sec_end
