#!/bin/sh

# &fullscreen=
if [ "${QUERY_STRING}" != "" ] && [ "$FULLSCREEN" = "" ]; then
	FULLSCREEN=`echo ${QUERY_STRING} | sed -n 's/.*fullscreen=\(.*\)/\1/p' | sed -e 's/&.*//g'`
fi

head_begin

PAGE=""
HELPPAGE=""
RESET=""
WEBIFPASS=""
NEWPATH=""
START=""
DELETE=""
RUN_CMD=""
CLOSE_CMD=""
FILE_SEL=""

# read get variables
if [ "${QUERY_STRING}" != "" ]; then

	# &page=
	if [ "$PAGE" = "" ]; then
		PAGE=`echo ${QUERY_STRING} | sed -n 's/.*page=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi

	# &help=
	if [ "$HELPPAGE" = "" ]; then
		HELPPAGE=`echo ${QUERY_STRING} | sed -n 's/.*help=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi

	# &direct_edit=
	_DIRECT_EDIT=`echo ${QUERY_STRING} | sed -n 's/.*direct_edit=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	if [ ! -z "$_DIRECT_EDIT" ]; then DIRECT_EDIT="$_DIRECT_EDIT"; fi

	# &new_patht=
	if [ "$NEWPATH" = "" ]; then
		NEWPATH=$($HTTPD -d "`echo ${QUERY_STRING} | sed -n 's/.*new_path=\(.*\)/\1/p' | sed -e 's/&.*//g'`")
	fi

	# &webifpass=
	if [ "$WEBIFPASS" = "" ]; then
		WEBIFPASS=$($HTTPD -d "`echo ${QUERY_STRING} | sed -n 's/.*webifpass=\(.*\)/\1/p' | sed -e 's/&.*//g'`")
	fi

	# &new_path=
	if [ "$NEWPATH" = "" ]; then
		NEWPATH=$($HTTPD -d "`echo ${QUERY_STRING} | sed -n 's/.*new_path=\(.*\)/\1/p' | sed -e 's/&.*//g'`")
	fi

	# &reset=
	if [ "$RESET" = "" ]; then
		RESET=`echo ${QUERY_STRING} | sed -n 's/.*reset_type=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi
	if [ "$RESET" != "" ]; then

		if [ "$RESET" = "path" ];
		then
			show_title "Pfad ändern"

			# stop dtmfbox
			/var/dtmfbox/rc.dtmfbox stop

			# No path? Then install to /var/dtmfbox-bin
			if [ "$NEWPATH" = "" ] || [ "$NEWPATH" = "/var/dtmfbox" ]; then
				NEWPATH="/var/dtmfbox-bin"
			fi

			echo "<br><br>"
			echo "Pfad wird auf \"$NEWPATH\" geändert.<br>"
			echo "Bitte warten, bis alle Dateien kopiert wurden...<br><br>"

			if [ "$DTMFBOX_PATH" = "$NEWPATH" ]; then
				echo "<b>Hinweis:</b> Alter und neuer Pfad nicht unterschiedlich!<br>"
				echo "<br>Abgebrochen!"
				head_end
				return 1;
			fi

			echo -n "<pre class='code'>"

			# Copy required files to new path
			mkdir -p $NEWPATH
			if [ "$FREETZ" = "0" ];
			then
				# Copy the current files (minimum)
				cp -Rf /var/dtmfbox/rc.dtmfbox $NEWPATH
				cp -Rf /var/dtmfbox/dtmfbox $NEWPATH
				cp -Rf /var/dtmfbox/busybox-tools $NEWPATH
				cp -Rf /var/dtmfbox/script $NEWPATH
				cp -Rf /var/dtmfbox/httpd $NEWPATH
				cp -Rf /var/dtmfbox/default $NEWPATH
				cp -Rf /var/dtmfbox/*.so $NEWPATH
				cp -Rf /var/dtmfbox/*.cfg $NEWPATH

				# USB? Then copy all files (including recordings)...
				if [ "$NEWPATH" != "/var/dtmfbox-bin" ]; then
					cp -Rf /var/dtmfbox/* $NEWPATH
				fi
			fi

			# Save config
			export DTMFBOX_PATH="$NEWPATH"			# Export new pathname
			rm /var/dtmfbox					# Remove link dir

			if [ "$FREETZ" = "0" ]; then
 			  $DTMFBOX_PATH/rc.dtmfbox check_busybox	# Relink busybox
			  $DTMFBOX_PATH/rc.dtmfbox install bypath	# Reinstall dtmfbox (USB/RAM)
			else
			  /mod/etc/init.d/rc.dtmfbox install bypath		# Reinstall dtmfbox (FREETZ)
			fi

			echo -n "</pre>"

			show_page "dtmfbox_scriptedit.cgi" "SAVE"	# Save config (change debug.cfg)

			# Finished!
			echo "<br>Fertig!"
			head_end
			return 1;
		fi

		if [ "$RESET" = "reset" ];
		then
			show_title "Die Konfiguration wird zurückgesetzt..."
			echo -n "<pre class='code'>"
			/var/dtmfbox/rc.dtmfbox defaults
			echo -n "</pre> Fertig!"
			head_end
			return 1;
		fi

		if [ "$RESET" = "uninstall" ];
		then
			show_page "dtmfbox_scriptedit.cgi" "UNINSTALL"
			show_title "dtmfbox deinstallieren..."

			# stop dtmfbox
			/var/dtmfbox/rc.dtmfbox stop >/dev/null

			# remove entry from /var/flash/debug.cfg
			/var/dtmfbox/rc.dtmfbox uninstall

			rm /var/dtmfbox

			echo "<br>Fertig!"
			head_end
			return 1;
		fi

		if [ "$RESET" = "password" ];
		then
			if [ ! -z "$WEBIFPASS" ];
			then
				# save pass to httpd.conf
				WEBIFPASS_ENC="/:admin:`$HTTPD -m $WEBIFPASS`"
				echo "$WEBIFPASS_ENC" > /var/dtmfbox/httpd/httpd.conf
			else
				rm /var/dtmfbox/httpd/httpd.conf
			fi

			show_page "dtmfbox_scriptedit.cgi" "SAVE"
			echo "<font size='2'><a href='$MAIN_CGI&page=status'><< zurück zur Statusseite...</a></font>"

			# reload httpd configuration
			kill -1 0
			sleep 1
			return 1;
		fi
	fi

	# &delete=true
	if [ "$DELETE" = "" ]; then
		DELETE=`echo ${QUERY_STRING} | sed -n 's/.*delete=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi
	if [ "$DELETE" = "true" ]; then

		# read security PID for runcmd!
		if [ -f /var/dtmfbox/tmp/webinterface.pid ];
		then
			SEC_PID1=`echo ${QUERY_STRING} | sed -n 's/.*pid=\(.*\)/\1/p' | sed -e 's/&.*//g'`
			SEC_PID2=`cat /var/dtmfbox/tmp/webinterface.pid`

			# both PIDs equal? Then run!
			if [ "$SEC_PID1" = "$SEC_PID2" ];
			then

				if [ "$CMD_LOCAL" = "" ]; then
					CMD_LOCAL=`echo ${QUERY_STRING} | sed -n 's/.*cmd_local=\(.*\)/\1/p' | sed -e 's/&.*//g'`
					CMD_LOCAL=$($HTTPD -d "$CMD_LOCAL")
					echo "$CMD_LOCAL" > /var/dtmfbox/tmp/dtmfbox_delete_local.sh
					chmod +x /var/dtmfbox/tmp/dtmfbox_delete_local.sh
					. /var/dtmfbox/tmp/dtmfbox_delete_local.sh
					rm /var/dtmfbox/tmp/dtmfbox_delete_local.sh
				fi

				if [ "$CMD_REMOTE" = "" ]; then
					CMD_REMOTE=`echo ${QUERY_STRING} | sed -n 's/.*cmd_remote=\(.*\)/\1/p' | sed -e 's/&.*//g'`
					CMD_REMOTE=$($HTTPD -d "$CMD_REMOTE")
					echo "$CMD_REMOTE" > /var/dtmfbox/tmp/dtmfbox_delete_ftp.sh
					chmod +x /var/dtmfbox/tmp/dtmfbox_delete_ftp.sh
					echo "<pre>"
					. /var/dtmfbox/tmp/dtmfbox_delete_ftp.sh
					echo "</pre>"
					rm /var/dtmfbox/tmp/dtmfbox_delete_ftp.sh
				fi
			fi
		fi
	fi

	# &start=
	if [ "$START" = "" ]; then
		START=`echo ${QUERY_STRING} | sed -n 's/.*start=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi
	if [ "$START" != "" ];
	then
		# Daemon starten
		if [ "$START" = "daemon" ];
		then
			/var/dtmfbox/rc.dtmfbox restart > /dev/null
		fi

		# Daemon geloggt starten
		if [ "$START" = "logged" ];
		then
			/var/dtmfbox/rc.dtmfbox stop >/dev/null
			rm /var/dtmfbox/tmp/dtmfbox.log 2>/dev/null
			/var/dtmfbox/rc.dtmfbox log >/dev/null
			touch /var/dtmfbox/tmp/dtmfbox.log
		fi

		# Daemon stoppen
		if [ "$START" = "stop" ];
		then
			/var/dtmfbox/rc.dtmfbox stop >/dev/null
		fi

		# Fritzbox rebooten
		if [ "$START" = "reboot" ];
		then
			echo "<pre>Reboot wird durchgeführt...</pre>"
			echo "<div style='display:none'>"
			reboot
			return 1;
		fi
	fi

	# &close=
	if [ "$CLOSE_CMD" = "" ]; then
		CLOSE_CMD=`echo ${QUERY_STRING} | sed -n 's/.*close=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi

	# &run_cmd=
	if [ "$RUN_CMD" = "" ]; then
		RUN_CMD=`echo ${QUERY_STRING} | sed -n 's/.*run_cmd=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi

	if [ "$RUN_CMD" != "" ];
	then
		# read security PID for runcmd!
		if [ -f /var/dtmfbox/tmp/webinterface.pid ];
		then
			SEC_PID1=`echo ${QUERY_STRING} | sed -n 's/.*pid=\(.*\)/\1/p' | sed -e 's/&.*//g'`
			SEC_PID2=`cat /var/dtmfbox/tmp/webinterface.pid`

			# both PIDs equal? Then run!
			if [ "$SEC_PID1" = "$SEC_PID2" ];
			then
				RUN_CMD=$($HTTPD -d "$RUN_CMD")
				$RUN_CMD >/dev/null 2>/dev/null

				if [ "$CLOSE_CMD" = "1" ];
				then
					echo "Fenster wird geschlossen! Bitte warten..."
					echo "<script language='javascript'>window.close()</script>"
					exit 1;
				fi
			fi
		fi
	fi

fi
if [ "$PAGE" = "" ]; then PAGE="status"; fi

# returns am-messages to $status_recordings (as links)
get_am_messages() {

  . /var/dtmfbox/script/funcs.sh

  status_recordings=""
  let tmp_acc_no=$DTMFBOX_MAX_ACCOUNTS;
  while [ $tmp_acc_no -ge 1 ];
  do
	let msg_cnt=0;
	for file in `find $DTMFBOX_PATH/record/${tmp_acc_no}/* 2>/dev/null`
	do
		if [ ! -d $file ]; then
			let msg_cnt=msg_cnt+1
		fi
	done

	if [ "$msg_cnt" != "0" ];
	then
		get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc${tmp_acc_no}" "name"
		status_recordings="<a href='$MAIN_CGI&page=am_messages&acc=${tmp_acc_no}'>Account #${tmp_acc_no} ($CFG_VALUE) - $msg_cnt Nachricht(en)</a><br>$status_recordings"
	fi
	let tmp_acc_no=$tmp_acc_no-1
  done
}

# Security PID for run_cmd= and dtmfbox_cmd.cgi!
echo "$$" > /var/dtmfbox/tmp/webinterface.pid

####################################################################################
## STATUS
####################################################################################
if [ "$PAGE" = "status" ];
then
  show_title "Status"

  # Get am messages to $status_recordings
  get_am_messages

  if [ "$status_recordings" != "" ]; then
    echo "<pre style='font-size:11px' width='70%'>$status_recordings</pre><br>"
  fi

cat << EOF
	<table style='border: 1px solid #AAAAAA;' cellpadding='3' cellspacing='0' width='95%'><tr><td>
	<div name='status'>
	<iframe src="./dtmfbox_status.cgi?pid=$$" width='100%' height='350' frameborder='0' scrolling='horizontal'></iframe>
	</div>
	</td></tr>
	<tr><td bgcolor='silver' width="100%">
	<table border="0" width="100%" cellpadding='0' cellspacing='0'><tr>
	<td align='left'><b>Installiert unter: $DTMFBOX_PATH</b></td>
EOF
if [ "$DTMFBOX_APACHE" != "1" ]; then
cat << EOF
	<td align='right'><input type='button' value='Pfad ändern' name='change_path' onclick="javascript:location.href='$MAIN_CGI&page=reset_path_only'"></td>
EOF
fi

cat << EOF
	</tr></table>
	</td></tr></table>
EOF
fi

####################################################################################
## Basiseinstellungen
####################################################################################
if [ "$PAGE" = "dtmfbox_cfg" ];
then
  FILE_EDIT="/var/dtmfbox/dtmfbox.cfg";
  SHOW_FILE_SELECTION="0"
  CHECK_REBOOT="1"
  COMMENT_PREFIX="//"
  if [ -z "$DIRECT_EDIT" ]; then DIRECT_EDIT="0"; fi
  show_page "dtmfbox_scriptedit.cgi"
fi

####################################################################################
## Skripteinstellungen
####################################################################################
if [ "$PAGE" = "script_cfg" ];
then
  FILE_EDIT="/var/dtmfbox/script.cfg";
  SHOW_FILE_SELECTION="0"
  CHECK_REBOOT="0"
  COMMENT_PREFIX="#"
  if [ -z "$DIRECT_EDIT" ]; then DIRECT_EDIT="0"; fi
  show_page "dtmfbox_scriptedit.cgi"
fi

####################################################################################
## Menü bearbeiten
####################################################################################
if [ "$PAGE" = "menu_cfg" ];
then
  FILE_EDIT="/var/dtmfbox/menu.cfg";
  SHOW_FILE_SELECTION="0"
  CHECK_REBOOT="1"
  COMMENT_PREFIX="//"
  SHOW_ADD_REMOVE="1"
  if [ -z "$DIRECT_EDIT" ]; then DIRECT_EDIT="0"; fi
  show_page "dtmfbox_scriptedit.cgi"
fi

####################################################################################
## Skripte bearbeiten
####################################################################################
if [ "$PAGE" = "scripts" ];
then
  SHOW_CONFIG_FILES="0"
  CHECK_REBOOT="0"
  DIRECT_EDIT="1"
  show_page "dtmfbox_scriptedit.cgi"
fi

####################################################################################
## Webphone
####################################################################################
if [ "$PAGE" = "webphone" ];
then
show_title "Java Webphone"
echo '<a name="webphone" href="#webphone"></a>'
echo '<div id="form_webphone" style="display:block">'
echo '<form name="webphone" method="get">'

let LOC_RTP_START=$WEBPHONE_LOC_RTP_PORT
let LOC_RTCP_START=$LOC_RTP_START+1
let REM_RTP_START=$WEBPHONE_REM_RTP_PORT
let REM_RTCP_START=$REM_RTP_START+1

if [ ! -z "$(pidof 'dtmfbox')" ];
then
	dtmfbox_running="1"
else
	dtmfbox_running="0"
fi

cat << EOF
<script>
function change_webphone_account(acc_idx)
{
	var opt=document.getElementById('account').options[acc_idx].text;
	if(opt.indexOf('(capi)') != -1 ) {
		document.getElementById('capi_controller').style.display='block';
		document.getElementById('capi_controller_caption').style.display='block';
	} else {
		document.getElementById('capi_controller').style.display='none';
		document.getElementById('capi_controller_caption').style.display='none';
	}
}

function webphone_dial()
{
	var trg_no = document.getElementById('trg_no');
	var account =  document.getElementById('account');
	var controller_div = document.getElementById('capi_controller');
	var controller = document.getElementById('selected_controller');
	var dtmfbox_path="$DTMFBOX_PATH";

	var controller_value = '';

	if(controller_div.style.display != "none") {
		controller_value = controller.value;
		if(controller_value == "0") {
			controller_value = '';
		}
	}
	if(trg_no.value == '')
	{
		alert('Bitte Telefonnummer eingeben!');
		return;
	};
	if(account.value == '')
	{
		alert('Bitte Account wählen!');
		return;
	};

	window.open('$MAIN_CGI&page=$PAGE&close=1&pid=$$&run_cmd=/bin/sh%20dtmfbox_webphone.cgi%20CALL%20${REMOTE_ADDR}%20$LOC_RTP_START%20$REM_RTP_START%20' + escape(dtmfbox_path) + '%20' + escape(account.value) + '%20' + escape(trg_no.value) + '%20' + escape(controller_value) + '%20');
}

function webphone_hangup()
{
	var trg_no = document.getElementById('trg_no');
	var account =  document.getElementById('account');
	var controller = document.getElementById('selected_controller');
	var dtmfbox_path="$DTMFBOX_PATH";

	window.open('$MAIN_CGI&page=$PAGE&close=1&pid=$$&run_cmd=/bin/sh%20dtmfbox_webphone.cgi%20HANGUP%20${REMOTE_ADDR}%20$LOC_RTP_START%20$REM_RTP_START%20' + escape(dtmfbox_path) + '%20' + escape(account.value) + '%20' + escape(trg_no.value) + '%20');
}
</script>
EOF

if [ "$dtmfbox_running" = "1" ];
then
if [ -f "../sWebPhone.jar" ]; then
	WEBPHONE_CODEBASE="../"
else
	WEBPHONE_CODEBASE="./"
fi

cat << EOF
	<applet code="WebPhone" archive="sWebPhone.jar" codebase="$WEBPHONE_CODEBASE" HEIGHT="200" style="width:95%">
	<PARAM NAME="remote_addr" VALUE="$WEBPHONE_REM_RTP_HOST">
	<PARAM NAME="remote_rtp" VALUE="$REM_RTP_START">
	<PARAM NAME="remote_rtcp" VALUE="$REM_RTCP_START">
	<PARAM NAME="local_rtp" VALUE="$LOC_RTP_START">
	<PARAM NAME="local_rtcp" VALUE="$LOC_RTCP_START">
	</applet>
<br>
<table border="0" width="95%">
<tr><td width="100px">Account:</td>
<td>
	<select name="account" id="account" onchange="javascript:change_webphone_account(this.selectedIndex)">
EOF

let i=1
let cnt=1
. /var/dtmfbox/script/funcs.sh

while [ $i -le $DTMFBOX_MAX_ACCOUNTS ];
do
get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc${i}" "active";
let DTMFBOX_ACC_ACTIVE=$CFG_VALUE

if [ "$DTMFBOX_ACC_ACTIVE" = "1" ];
then
	get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc${i}" "number";
	DTMFBOX_ACC_NUMBER=`echo "$CFG_VALUE" | sed 's/.*#//g'`
	get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc${i}" "type";
	DTMFBOX_ACC_TYPE=`echo "$CFG_VALUE"`

    	DTMFBOX_ACC_NUMBER=`echo "$DTMFBOX_ACC_NUMBER"`
	echo "<option name=\"account_value_${cnt}\" id=\"account_value_${cnt}\" value=\"$DTMFBOX_ACC_NUMBER\">($DTMFBOX_ACC_TYPE) - $DTMFBOX_ACC_NUMBER</option>"
	let cnt=cnt+1
fi
let i=i+1
done

cat << EOF
	</select>
</td>
</tr><tr>
<td width="100px">
	<div name='capi_controller_caption' id='capi_controller_caption' style='display:block'>
		CAPI-Controller:
	</div>
</td>
<td>
 	<div name='capi_controller' id='capi_controller' style='display:block'>
		<select name='selected_controller' id='selected_controller'>
			<option value='1'>1 (ISDN)</option>
			<option value='3'>3 (Intern)</option>
			<option value='4'>4 (Analog)</option>
			<option value='5'>5 (VoIP)</option>
		</select>
	</div>
</td>
</tr><tr>
<td width="100px">Rufnummer:</td>
<td>
<input type="text" name="trg_no" id="trg_no">
<input type="button" value="Wählen" onclick="javascript:webphone_dial()">
<input type="button" value="Auflegen"  onclick="javascript:webphone_hangup()">
<input type='hidden' name='pkg' value='dtmfbox'>
</td>
</tr></table>

<script>
	change_webphone_account(0);
</script>
EOF
echo '<br>'

# STATUS:
echo "<div name='status'>"
echo "<iframe src=\"./dtmfbox_status.cgi?no_startstop=1&pid=$$\" width='95%' height='200' frameborder='0' scrolling='horizontal'></iframe>"
echo "</div>"
echo '<br><br><br>'

else
echo "<font style='color:red'><b><i>dtmfbox not running!</i></b></font>"
fi
echo '</form>'
echo '</div>'
fi

####################################################################################
## dtmfbox zurücksetzen
####################################################################################
if [ "$PAGE" = "reset" ] || [ "$PAGE" = "reset_path_only" ];
then
  if [ "$PAGE" != "reset_path_only" ]; then
	  show_title "Pfad, Reset, Deinstallieren, WebIf-Passwort ..."
  else
	  show_title "Pfad ändern ..."
  fi
  echo "<form name='freset' method='get'>"
cat << EOF
<script>
function submit_reset_options()
{
	var text = "";
	var option=document.forms['freset']['reset_type'].value;
	if(option == 'reset') { text = "Konfiguration zurücksetzen?\n\nDadurch werden die Standardskripte und Einstellungen wiederhergestellt."; }
	if(option == 'uninstall') { text = "dtmfbox deinstallieren?"; }

	if(option == 'path') {
		new_path=document.forms['freset']['new_path'].value;
		if(new_path == '' || new_path == '/var/dtmfbox')
			new_path = '/var/dtmfbox-bin';

		if(new_path == "$DTMFBOX_PATH") {
			alert("Bitte einen anderen Pfad angeben!");
			return;
		} else {
			text = "Neuen Pfad setzen?\n\n" + "Von: $DTMFBOX_PATH\nNach: " + new_path;
		}
	}

	if(option == 'password') {
		pass1=document.forms['freset']['webifpass'].value;
		pass2=document.forms['freset']['webifpass2'].value;
		if(pass1 != pass2) {
			alert("Die eingegebenen Passwörter sind unterschiedlich!");
			return;
		}
		if(pass1 == "") {
			text = "Webinterface-Passwort entfernen?";
		} else {
			text = "Webinterface-Passwort setzen?";
		}
	}

	if(confirm(text)) {
		document.forms['freset'].submit();
	}
}

function change_reset_options()
{
	var option=document.forms['freset']['reset_type'].value;

	document.getElementById('passworddiv').style.display = "none";
	document.getElementById('pathdiv').style.display = "none";

	if(option == 'password')  {
		document.getElementById('passworddiv').style.display = "block";
		document.forms['freset']['webifpass'].focus();
	} else {
		if(option == 'path') {
			document.getElementById('pathdiv').style.display = "block";
			document.forms['freset']['new_path'].focus();
		}
	}
}
</script>
EOF
  echo "<input type='hidden' name='dummy1' value='0'>"
  echo "<input type='hidden' name='pkg' value='dtmfbox'>"
  echo "<b>Auswahl:</b> <select name='reset_type' onchange='javascript:change_reset_options()'>"
  echo "<option value='path'>Pfad ändern</option>"
  if [ "$PAGE" != "reset_path_only" ];
  then
	  echo "<option value='reset'>Konfiguration zurücksetzen</option>"
	  echo "<option value='uninstall'>Deinstallieren</option>";
	  if [ "$FREETZ" = "0" ]; then echo "<option value='password'>Webinterface Passwort</option>"; fi
  fi
  echo "</select>"
  echo "<input type='button' name='btnReset' value='OK' onclick='javascript:submit_reset_options()'>"
  echo "<input type='hidden' name='dummy2' value='0'>"

  echo "<div style='display:none' name='passworddiv' id='passworddiv'><br><br>"
  echo "<table border='0'>"
  echo "<tr><td><b>Passwort:</b></td> <td><input type='password' name='webifpass' value='' size='16' maxlength='16' style='width:150px'></td></tr>";
  echo "<tr><td><b>Bestätigen:</b></td> <td><input type='password' name='webifpass2' value='' size='16' maxlength='16' style='width:150px'></td></tr>";
  echo "</table>"
  echo "<br><font size='1'>Leer lassen, falls kein Passwort!<br>Username: admin</font><br>"
  if [ ! -f "/var/dtmfbox/httpd/httpd.conf" ]; then echo "<br><font size='2'><b>Hinweis: z.Zt. ist kein Passwort hinterlegt!</b></font>"; fi
  echo "</div>"

  echo "<div style='display:block' name='pathdiv' id='pathdiv'><br><br>"
  echo "<table border='0'>"
  echo "<tr><td><b>Neuer Pfad:</b></td> <td><input type='text' name='new_path' value='$DTMFBOX_PATH' style='width:350px'> </td></tr>"
  echo "<tr><td></td> <td><font size='1'><b>Leer lassen, falls kein USB!</b></font></td></tr>"
  echo "</table>"
  echo "</div>"
  echo "</form>"

  if [ "$FREETZ" = "1" ] && [ -z "$DTMFBOX_PATH" ];
  then
	head_end
	return
  fi
fi

####################################################################################
## Nachrichten
####################################################################################
if [ "$PAGE" = "am_messages" ];
then

	let ITEMS_PER_PAGE=10

	acc_no_str=`echo ${QUERY_STRING} | sed -n 's/.*acc=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	page_str=`echo ${QUERY_STRING} | sed -n 's/.*page_msg=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	if [ -z "$page_str" ]; then page_str="1"; fi
	if [ -z "$acc_no_str" ]; then acc_no_str="1"; fi
	let acc_no=$acc_no_str
	let page=$page_str
	let page=page-1;
	if [ $page -le 0 ] || [ "$page" = "" ]; then let page=0; fi
	if [ $acc_no -le 0 ] || [ "$acc_no" = "" ]; then acc_no="1"; fi

	# load ftp account settings from funcs.sh script
        if [ -f /var/dtmfbox/script/funcs.sh ];
	then
		. /var/dtmfbox/script/am_funcs.sh
		load_am_settings "${acc_no}"
	fi

	delimiter="\n"
	ftp_user="$AM_FTP_USERNAME"
	ftp_pass="$AM_FTP_PASSWORD"
	ftp_path="$AM_FTP_PATH"
	ftp_server="$AM_FTP_SERVER"
	ftp_port="$AM_FTP_PORT"

	ftp_login=`eval echo "USER \\$ftp_user\"$delimiter\"PASS \\$ftp_pass\"$delimiter\"CWD \\$ftp_path\"$delimiter\""`

cat << EOF
	<script language="javascript">

	function delete_recordings(rec_cnt)
	{
		var cmd_local="";
		var cmd_remote="";

		for(j=0; j<document.forms.length; j++)
		{
			for(i=0; i<rec_cnt; i++)
			{
				try
				{
					if(document.forms[j]['recording' + i].checked)
					{
						// delete local file
						cmd_local = cmd_local + 'rm ' + document.forms[j]['recfile' + i].value + ';';

						// delete remote file
						if(document.forms[j]['is_ftp' + i].value == "FTP") {
							if(cmd_remote.length == 0)
							cmd_remote="cat << EOF > /var/dtmfbox/tmp/nc_ftp_cmd\n$ftp_login";

							cmd_remote = cmd_remote + 'DELE ' + document.forms[j]['recfilename' + i].value + '\n';
						}
					}
				} catch(e) {}
			}
		}
		if(cmd_remote.length > 0) {
			cmd_remote = cmd_remote + "QUIT\nEOF\n";
			cmd_remote = cmd_remote + "cat /var/dtmfbox/tmp/nc_ftp_cmd | $NC $ftp_server:$ftp_port;\n"
			cmd_remote = cmd_remote + "rm /var/dtmfbox/tmp/nc_ftp_cmd;\n"
		}

		if(cmd_local.length > 0)
		{
			cmd_local=escape(cmd_local);
			cmd_remote=escape(cmd_remote);
			this.document.location.href="$MAIN_CGI&pid=$$&page=am_messages&acc=$acc_no&delete=true&cmd_local=" + cmd_local + "&cmd_remote=" + cmd_remote
		}
	}
	</script>
EOF

	echo '<a name="am_recordings" href="#am_recordings"></a>'
	echo '<div id="form_am_recordings" style="display:block">'

	show_title "Aufnahmen - Account #${acc_no}"

	echo "<form name='am_message'>"
	echo "<table border='1' cellpadding='5' cellspacing='0' width='95%' bordercolor='black'><tr><td>"
	echo "<table border='0' cellpadding='1' cellspacing='0' width='100%'>"

	echo "<tr>"
	echo "<td width='25' align='center' bgcolor='black'></td>"
	echo "<td width='40' align='center' bgcolor='black'><font color='white'><b>FTP/HDD</b></font></td>"
	echo "<td width='175' align='center' bgcolor='black'><font color='white'><b>Datum, Uhrzeit</b></font></td>"
	echo "<td width='55' align='center' bgcolor='black'><font color='white'><b>Länge</b></font></td>"
	echo "<td width='10' bgcolor='black'></td>"
	echo "<td bgcolor='black'><font color='white'><b>Nummer</b></font></td>"
	echo "<td width='75' bgcolor='black'></td></tr><tr>"

	let rec_no=1
	let p=0;
	let position=0;
	let start_position="$page"
	let start_position=start_position*$ITEMS_PER_PAGE;
	let end_position=$start_position+$ITEMS_PER_PAGE-1;
	for file in `ls -r $DTMFBOX_PATH/record/$acc_no/* 2>/dev/null`
	do
	if [ -f $file ]; then

		if [ $position -ge $start_position ] && [ $position -le $end_position ];
		then

		filename=`echo $file | sed 's/^.*\/\(.*\..*\)$/\1/g'`
		FILE_DATE=`echo $filename | sed 's/^\(..\).\(..\).\(..\)--\(..\).\(..\).*$/\3.\2.20\1, \4:\5/g'`
		CALLER_NO=`echo $filename | sed 's/^.*---.*-\(.*\)[\.]...$/\1/g'`
		ACCOUNT_NO=`echo $filename | sed 's/^.*---\(.*\)-.*$/\1/g'`
		IS_FTP=`echo $filename | sed 's/^.*\.raw$/FTP/g'`
		if [ "$IS_FTP" != "FTP" ];
		then
			let FILE_DURATION=`$DU "$file" | sed -e "s/\([0-9]*\).*/\1/g"`
			let FILE_DURATION=$FILE_DURATION*1024/17500
			FILE_DURATION="$FILE_DURATION sec"
		else
			FILE_DURATION="~"
		fi

		if [ "$IS_FTP" != "FTP" ]; then IS_FTP="HDD"; else IS_FTP="FTP"; fi

		if [ "$IS_FTP" != "FTP" ]; then
			DOWNLOAD_CMD="dtmfbox_cmd.cgi?pid=$$&script=cat%20$file&binary=true&download_name=$filename"
		else
			DOWNLOAD_CMD="ftp://$ftp_user:$ftp_pass@$ftp_server:$ftp_port/$ftp_path/$filename"
		fi

		if [ $p -eq 0 ]; then
			echo "<tr bgcolor='#EEEEEE'>"
		else
			echo "<tr bgcolor='#DFDFDF'>"
		fi

		echo "<td width='25'><div align='center'><input type='hidden' value=\"$filename\" name=\"recfilename${rec_no}\" id=\"recfilename${rec_no}\"><input type='hidden' value=\"$file\" name=\"recfile${rec_no}\" id=\"recfile${rec_no}\"><input type='hidden' value=\"$IS_FTP\" name=\"is_ftp${rec_no}\" id=\"is_ftp${rec_no}\"><input type='checkbox' name=\"recording${rec_no}\" id=\"recording${rec_no}\"></div></td>"
		echo "<td width='40'><div align='center'>$IS_FTP</div></td>"
		echo "<td width='175'><div align='center'>$FILE_DATE</div></td>"
		echo "<td width='55'><div align='right'>$FILE_DURATION</div></td>"
		echo "<td width='10'></td>"
		echo "<td>$CALLER_NO an $ACCOUNT_NO</td>"
		echo "<td width='75'><div align='center'><input type='button' value='Anhören' onclick=\"javascript:win=window.open('$DOWNLOAD_CMD');\" style='width:75px'></div></td>"
		echo "</tr>"

		let rec_no=rec_no+1;
		let p=p+1;
		if [ $p -eq 2 ]; then p=0; fi
		fi

		let position=position+1;
	fi
	done
	echo "</table><br>"

	echo "<table border='0' width='100%' cellpadding='0' cellspacing='0'><tr>"
	echo "<td align='left' width='175px'><input type='button' value='Auswahl umkehren' onclick=\"javascript:for(j=0; j<document.forms.length;j++) { for(i=0; i<${rec_no}; i++) { try { document.forms[j]['recording' + i].checked = !document.forms[j]['recording' + i].checked; } catch(e) {} } }\" style='width:150px'></td>"

	let pages=$position/$ITEMS_PER_PAGE;
	let pages2=$pages*$ITEMS_PER_PAGE;
	if [ "$pages2" -ne "$position" ]; then let pages=pages+1; fi

	echo "<td align='left'>$position Nachricht(en) - Seite: "
	let page=1;
	while [ $page -le $pages ];
	do
		let p=$page-1;
		echo -n "<a href='$MAIN_CGI&page=$PAGE&acc=$acc_no&page_msg=$page'>$page</a>"
		if [ $page -ne $pages ]; then echo -n ", "; fi
		let page=page+1
	done
	echo "</td>"
	echo "<td align='right'><input type='button' value='Löschen' onclick=\"javascript:delete_recordings($rec_no)\" style='width:75px'></td>"
	echo "</tr></table>"
	echo '</div></tr></table>'

	# show links to other accounts
	get_am_messages
	echo "<pre>$status_recordings</pre>"
	echo "<input type='hidden' name='pkg' value='dtmfbox'>"
	echo '</form>'
fi


####################################################################################
## Hilfe
####################################################################################
if [ "$PAGE" = "help" ];
then
  show_page "dtmfbox_help.cgi"
else
  if [ "$FULLSCREEN" != "1" ]; then
	head_end
  else
	echo "</td></tr></table></body></html>"
  fi
fi

