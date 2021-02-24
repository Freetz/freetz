#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SSHFS_FUSE_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Public Key Authentication" en:"Public key authentication")"

cat << EOF
<p><i>$(lang de:"SSHFS funktioniert nur, wenn unter 'SSH known_hosts' der Schl&uuml;ssel f&uuml;r den Zielhost hinterlegt ist." en:"You should add the remote host to the global ssh_known_hosts file. Otherwise sshfs will fail unless the user has ssh'ed to the host before."):</i></p>
<ul>
<li><a href="$(href file authorized-keys known_hosts)">$(lang de:"known_hosts bearbeiten" en:"Edit known_hosts")</a></li>
</ul>
<p><i>$(lang de:"Man kann das Passwort weglassen, wenn unter 'SSH authorized_keys' ein Userschl&uuml;ssel hinterlegt wurde." en:"In most cases it is better to use SSH keys and leave the password field emty."):</i></p>
<ul>
<li><a href="$(href file authorized-keys authorized_keys)">$(lang de:"authorized_keys bearbeiten" en:"Edit authorized_keys")</a></li>
</ul>
EOF
sec_end

sec_begin "$(lang de:"Freigaben" en:"Start shares")"

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

document.write("<div id='Acc1' style='display:block'><p><label id='acc1' for='r06'>Share: </label><input id='r06' type='text' name='share1' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_SHARE1")'></p>" +
"<p><label for='r03'>User: </label><input id='r03' type='text' name='user1' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_USER1")'></p>" +
"<p><label for='r04'>Pass: </label><input id='r04' type='password' name='pass1' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PASS1")'></p>" +
"<p><label for='r07'>Port: </label><input id='r07' type='test' name='port1' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PORT1")'></p>" +
"<hr color='silver'>" +
"<p><label for='r05'>Mountpoint: </label><input id='r05' type='text' name='mountpoint1' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_MOUNTPOINT1")'></p>" +
"</div>");

document.write("<div id='Acc2' style='display:none'><p><label id='acc2' for='r16'>Share: </label><input id='r16' type='text' name='share2' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_SHARE2")'></p>" +
"<p><label for='r13'>User: </label><input id='r13' type='text' name='user2' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_USER2")'></p>" +
"<p><label for='r14'>Pass: </label><input id='r14' type='password' name='pass2' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PASS2")'></p>" +
"<p><label for='r17'>Port: </label><input id='r17' type='text' name='port2' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PORT2")'></p>" +
"<hr color='silver'>" +
"<p><label for='r15'>Mountpoint: </label><input id='r15' type='text' name='mountpoint2' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_MOUNTPOINT2")'></p>" +
"</div>");

document.write("<div id='Acc3' style='display:none'><p><label id='acc3' for='r26'>Share: </label><input id='r26' type='text' name='share3' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_SHARE3")'></p>" +
"<p><label for='r23'>User: </label><input id='r23' type='text' name='user3' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_USER3")'></p>" +
"<p><label for='r24'>Pass: </label><input id='r24' type='passwort' name='pass3' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PASS3")'></p>" +
"<p><label for='r27'>Port: </label><input id='r27' type='text' name='port3' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PORT3")'></p>" +
"<hr color='silver'>" +
"<p><label for='r25'>Mountpoint: </label><input id='r25' type='text' name='mountpoint3' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_MOUNTPOINT3")'></p>" +
"</div>");

document.write("<div id='Acc4' style='display:none'><p><label id='acc4' for='r36'>Share: </label><input id='r36' type='text' name='share4' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_SHARE4")'></p>" +
"<p><label for='r33'>User: </label><input id='r33' type='text' name='user4' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_USER4")'></p>" +
"<p><label for='r34'>Pass: </label><input id='r34' type='passwort' name='pass4' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PASS4")'></p>" +
"<p><label for='r37'>Port: </label><input id='r37' type='text' name='port4' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PORT4")'></p>" +
"<hr color='silver'>" +
"<p><label for='r35'>Mountpoint: </label><input id='r35' type='text' name='mountpoint4' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_MOUNTPOINT4")'></p>" +
"</div>");

document.write("<div id='Acc5' style='display:none'><p><label id='acc5' for='r46'>Share: </label><input id='r46' type='text' name='share5' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_SHARE5")'></p>" +
"<p><label for='r43'>User: </label><input id='r43' type='text' name='user5' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_USER5")'></p>" +
"<p><label for='r44'>Pass: </label><input id='r44' type='passwort' name='pass5' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PASS5")'></p>" +
"<p><label for='r47'>Port: </label><input id='r47' type='text' name='port5' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_PORT5")'></p>" +
"<hr color='silver'>" +
"<p><label for='r45'>Mountpoint: </label><input id='r45' type='text' name='mountpoint5' size='50' maxlength='255' value='$(html "$SSHFS_FUSE_MOUNTPOINT5")'></p>" +
"</div>");
</script>

EOF

sec_end
