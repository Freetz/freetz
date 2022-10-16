#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$STREAMRIPPER_SERVER1_ENABLED" "yes":active1
check "$STREAMRIPPER_SERVER2_ENABLED" "yes":active2
check "$STREAMRIPPER_SERVER3_ENABLED" "yes":active3
check "$STREAMRIPPER_SERVER4_ENABLED" "yes":active4
check "$STREAMRIPPER_SERVER5_ENABLED" "yes":active5

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$STREAMRIPPER_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Filteregeln um bereits gerippte Dateien erg&auml;nzen" en:"Add ripped files to filter rules")"

cat << EOF
<ul>
<li><a href="$(href extra streamripper log)"> $(lang de:"Filterregeln erg&auml;nzen" en:"Complement filter rules")</a></li>
</ul>
EOF
sec_end

sec_begin "$(lang de:"Allgemeine Optionen" en:"Basic options")"

cat << EOF
<p><label for='r91'>$(lang de:"Startoptionen" en:"Startoptions"): </label><input id='r91' type='text' name='startoptions' size='70' maxlength='255' value='$(html "$STREAMRIPPER_STARTOPTIONS")'></p>
<p><label for='r92'>$(lang de:"Zielverzeichnis" en:"Target directory"): </label><input id='r92' type='text' name='musicdir' size='70' maxlength='255' value='$(html "$STREAMRIPPER_MUSICDIR")'></p>
EOF
sec_end

sec_begin 'Server'

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
"<OPTION SELECTED VALUE='0'>Server 1</OPTION>" +
"<OPTION VALUE='1'>Server 2</OPTION>" +
"<OPTION VALUE='2'>Server 3</OPTION>" +
"<OPTION VALUE='3'>Server 4</OPTION>" +
"<OPTION VALUE='4'>Server 5</OPTION>" +
"</SELECT></p>");

document.write("<div id='Acc1' style='display:block'><p><label id='acc1' for='r06'>Server URL: </label><input id='r06' type='text' name='server1' size='70' maxlength='255' value='$(html "$STREAMRIPPER_SERVER1")'></p>" +
"<p><label for='r02'>Name: </label><input id='r02' type='text' name='name1' size='50' maxlength='255' value='$(html "$STREAMRIPPER_NAME1")'></p>" +
"<p><input type='hidden' name='server1_enabled' value='no'><label for='r03'>Server enabled: </label><input id='r03' type='checkbox' name='server1_enabled' value='yes'$active1_chk></p>" +
"</div>");

document.write("<div id='Acc2' style='display:none'><p><label id='acc2' for='r16'>Server URL: </label><input id='r16' type='text' name='server2' size='70' maxlength='255' value='$(html "$STREAMRIPPER_SERVER2")'></p>" +
"<p><label for='r12'>Name: </label><input id='r12' type='text' name='name2' size='50' maxlength='255' value='$(html "$STREAMRIPPER_NAME2")'></p>" +
"<p><input type='hidden' name='server2_enabled' value='no'><label for='r13'>Server enabled: </label><input id='r13' type='checkbox' name='server2_enabled' value='yes'$active2_chk></p>" +
"</div>");

document.write("<div id='Acc3' style='display:none'><p><label id='acc3' for='r26'>Server URL: </label><input id='r26' type='text' name='server3' size='70' maxlength='255' value='$(html "$STREAMRIPPER_SERVER3")'></p>" +
"<p><label for='r22'>Name: </label><input id='r22' type='text' name='name3' size='50' maxlength='255' value='$(html "$STREAMRIPPER_NAME3")'></p>" +
"<p><input type='hidden' name='server3_enabled' value='no'><label for='r23'>Server enabled: </label><input id='r23' type='checkbox' name='server3_enabled' value='yes'$active3_chk></p>" +
"</div>");

document.write("<div id='Acc4' style='display:none'><p><label id='acc4' for='r36'>Server URL: </label><input id='r36' type='text' name='server4' size='70' maxlength='255' value='$(html "$STREAMRIPPER_SERVER4")'></p>" +
"<p><label for='r32'>Name: </label><input id='r32' type='text' name='name4' size='50' maxlength='255' value='$(html "$STREAMRIPPER_NAME4")'></p>" +
"<p><input type='hidden' name='server4_enabled' value='no'><label for='r33'>Server enabled: </label><input id='r33' type='checkbox' name='server4_enabled' value='yes'$active4_chk></p>" +
"</div>");

document.write("<div id='Acc5' style='display:none'><p><label id='acc5' for='r46'>Server URL: </label><input id='r46' type='text' name='server5' size='70' maxlength='255' value='$(html "$STREAMRIPPER_SERVER5")'></p>" +
"<p><label for='r42'>Name: </label><input id='r42' type='text' name='name5' size='50' maxlength='255' value='$(html "$STREAMRIPPER_NAME5")'></p>" +
"<p><input type='hidden' name='server5_enabled' value='no'><label for='r43'>Server enabled: </label><input id='r43' type='checkbox' name='server5_enabled' value='yes'$active5_chk></p>" +
"</div>");

</script>

EOF

sec_end
