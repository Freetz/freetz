#!/var/tmp/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox - fritz!box webif (c) 2008 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------
. ./dtmfbox_cfg.cgi

# first install? set default path
if [ "$DTMFBOX_PATH" = "" ]; then
	if [ "$FREETZ" = "0" ];
	then
		export DTMFBOX_PATH="`pwd | sed 's/\/httpd\/cgi-bin//g'`"
	else
		export DTMFBOX_PATH="/var/dtmfbox"
	fi

	FIRST_INSTALL="1"
fi

# process query string
if [ "${QUERY_STRING}" != "" ]; then

	# Param: current Page
	if [ "$CURRENT_PAGE" = "" ]; then
		CURRENT_PAGE=`echo ${QUERY_STRING} | sed -n 's/.*current_page=\(.*\)/\1/p' | sed -e 's/&.*//g'`	
	fi

#	if [ "$CURRENT_PAGE" = "" ];
#	then

	# Param: Command
	if [ "$CMD" = "" ]; then
		CMD=`echo ${QUERY_STRING} | sed -n 's/.*command=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi
	
	# execute a command
	if [ "$CMD" = "true" ]; then

	echo ""
	echo ""

	# Param: script
	script=`echo ${QUERY_STRING} | sed -n 's/.*script=\(.*\)/\1/p' | sed -e 's/&.*//'`
	script=$($HTTPD -d "$script")

	# Param: close
	close_window=`echo ${QUERY_STRING} | sed -n 's/.*close=\(.*\)/\1/p' | sed -e 's/&.*//'`
	
	# Run script
	echo "<pre>"
	echo "$script" | sed "s/$(echo -ne '\r')//g" | sh | sed -e 's/&/\&amp;/g ; s/</\&lt;/g ; s/>/\&gt;/g'
	echo "</pre>"
	
	# Close this window...
	if [ "$close_window" = "1" ]; then
		echo "<script>this.close();</script>"
	fi

	# Stop loading...
	echo "</div></td></tr></table></td></tr><tr></table></body></html>"
	echo "<script>"
	#echo "if(self.stop)"
	#echo "stop();"
	#echo "else if(document.execCommand)"
	#echo "document.execCommand('Stop');"
	echo "</script>"

	# alles was danach kommt, weg...
	echo '<div style="display:none"><textarea>'
	fi

	# Param: Delete
	if [ "$DELETE" = "" ]; then
		DELETE=`echo ${QUERY_STRING} | sed -n 's/.*delete=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi

	if [ "$DELETE" = "true" ]; then

		if [ "$CMD_LOCAL" = "" ]; then
		CMD_LOCAL=`echo ${QUERY_STRING} | sed -n 's/.*cmd_local=\(.*\)/\1/p' | sed -e 's/&.*//g'`
		CMD_LOCAL=$($HTTPD -d "$CMD_LOCAL")
		echo "$CMD_LOCAL" > /var/tmp/dtmfbox_delete_local.sh
		chmod +x /var/tmp/dtmfbox_delete_local.sh
		. /var/tmp/dtmfbox_delete_local.sh
		rm /var/tmp/dtmfbox_delete_local.sh
		fi	

		if [ "$CMD_REMOTE" = "" ]; then
		CMD_REMOTE=`echo ${QUERY_STRING} | sed -n 's/.*cmd_remote=\(.*\)/\1/p' | sed -e 's/&.*//g'`
		CMD_REMOTE=$($HTTPD -d "$CMD_REMOTE")
		echo "$CMD_REMOTE" > /var/tmp/dtmfbox_delete_ftp.sh
		chmod +x /var/tmp/dtmfbox_delete_ftp.sh
		echo "<pre>"
		. /var/tmp/dtmfbox_delete_ftp.sh
		echo "</pre>"
		rm /var/tmp/dtmfbox_delete_ftp.sh
		fi	
	fi

	# Param: Start/Stop/Start logged
	if [ "$START" = "" ]; then
		START=`echo ${QUERY_STRING} | sed -n 's/.*start=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	fi
	
	if [ "$START" != "" ];
	then
	
	# Daemon starten
	if [ "$START" = "daemon" ];
	then
		if [ "$FREETZ" = "1" ];
		then
		/etc/init.d/rc.dtmfbox restart > /dev/null
		else
		/var/dtmfbox/rc.dtmfbox restart > /dev/null
		fi
	fi
	
	# Daemon geloggt starten
	if [ "$START" = "logged" ];
	then
		if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
		rm $DTMFBOX_PATH/dtmfbox.log 2>/dev/null

		if [ "$FREETZ" = "1" ];
		then
		/etc/init.d/rc.dtmfbox stop
		/etc/init.d/rc.dtmfbox log > /dev/null
		else
		/var/dtmfbox/rc.dtmfbox stop
		/var/dtmfbox/rc.dtmfbox log > /dev/null
		fi
	fi
	
	# Daemon stoppen
	if [ "$START" = "stop" ];
	then
		if [ "$FREETZ" = "1" ];
		then
			/etc/init.d/rc.dtmfbox stop > /dev/null
		else
			/var/dtmfbox/rc.dtmfbox stop > /dev/null
		fi
	fi

	# Fritzbox rebooten
	if [ "$START" = "reboot" ];
	then
		echo "<pre>Reboot wird durchgeführt...</pre>"
		echo "<div style='display:none'>"
		reboot
		exit 1
	fi

# relocate
cat << EOF
	<script>location.href='${SCRIPT_NAME}?pkg=dtmfbox&current_page=$CURRENT_PAGE';</script>
EOF
	fi

#	fi
	# Param: Help
	if [ "$HELP" = "" ]; then
		HELP=`echo ${QUERY_STRING} | sed -n 's/.*help=\(.*\)/\1/p' | sed -e 's/&.*//g'`
	if [ "$HELP" != "" ]; then
		show_help
		exit 1
	fi
	fi	
fi



# Default page (status)
if [ "$CURRENT_PAGE" = "" ]; then
CURRENT_PAGE="status"
fi

# On every page, we need a status-field for usb (only needed by standalone & usb-version)
if [ "$DTMFBOX_PATH" = "" ] || [ "$DTMFBOX_PATH" = "/var/dtmfbox" ];
then
echo "<input type='hidden' name='got_usb_path' id='got_usb_path' value=\"$DTMFBOX_PATH\">"
echo "<input type='hidden' name='last_page' value='$CURRENT_PAGE'>"
echo "<input type='hidden' name='got_usb' id='got_usb' value='0'>"
else
echo "<input type='hidden' name='got_usb_path' id='got_usb_path' value=\"$DTMFBOX_PATH\">"
echo "<input type='hidden' name='last_page' value='$CURRENT_PAGE'>"
echo "<input type='hidden' name='got_usb' id='got_usb' value='1'>"
fi


# JavaScript for Accounts and answering machine
if [ "$CURRENT_PAGE" = "accounts" ] || [ "$CURRENT_PAGE" = "am" ] || [ "$CURRENT_PAGE" = "cbct" ];
then

cat << EOF
<script>

function change_account(value)
{
	for(t=0; t<document.forms.length; t++)
	{
		for(i=1; i<=10; i++)
		{
		try { document.getElementById("Acc_" + i).style.display = "none"; } catch(e) {}
		}

		try { document.getElementById("Acc_" + value).style.display = "block"; } catch(e) {}

		// Accounts
		try
		{
			var oActive = document.forms[t]["acc" + value + "_active"]
			change_active(oActive.value, value);
		} catch(e) {}

		// Answering machine
		try
		{
			var oActive = document.forms[t]["script_acc" + value + "_am"]
			change_active(oActive.value, value);
		} catch(e) {}

		// Callback / Callthrough
		try
		{
			var oActive = document.forms[t]["script_acc" + value + "_cbct_active"]
			change_cbct_active(oActive.value, value);
		} catch(e) {}
	}
}

function change_active(value, id)
{
	var disable;
	var i;
	if(value==0)
		disable = true;
	else
		disable = false;

	for(i=0; i<document.forms.length; i++)
	{
		try
		{		
			document.forms[i]["acc" + id + "_name"].disabled = disable;
			document.forms[i]["acc" + id + "_number"].disabled = disable;
			document.forms[i]["acc" + id + "_ctrl_out"].disabled = disable;
			document.forms[i]["acc" + id + "_type"].disabled = disable;
			document.forms[i]["acc" + id + "_voip_registrar"].disabled = disable;
			document.forms[i]["acc" + id + "_voip_realm"].disabled = disable;
			document.forms[i]["acc" + id + "_voip_proxy"].disabled = disable;
			document.forms[i]["acc" + id + "_voip_user"].disabled = disable;
			document.forms[i]["acc" + id + "_voip_pass"].disabled = disable;
			document.forms[i]["acc" + id + "_voip_id"].disabled = disable;
			document.forms[i]["acc" + id + "_voip_contact"].disabled = disable;
			document.forms[i]["acc" + id + "_registrar_active"].disabled = disable;
			document.forms[i]["script_acc" + id + "_ddi"].disabled = disable;
			} catch(e) {}

		try
		{
			document.forms[i]["script_acc" + id + "_am_pin"].disabled = disable;
			document.forms[i]["script_acc" + id + "_record"].disabled = disable;
			document.forms[i]["script_acc" + id + "_timeout"].disabled = disable;
			document.forms[i]["script_acc" + id + "_ringtime"].disabled = disable;
			document.forms[i]["script_acc" + id + "_announcement"].disabled = disable;
			document.forms[i]["script_acc" + id + "_announcement_end"].disabled = disable;
			document.forms[i]["script_acc" + id + "_unknown_only"].disabled = disable;
			document.forms[i]["script_acc" + id + "_beep"].disabled = disable;
			document.forms[i]["script_acc" + id + "_mail_active"].disabled = disable;
			document.forms[i]["script_acc" + id + "_ftp_active"].disabled = disable;
			document.forms[i]["script_acc" + id + "_on_at"].disabled = disable;
			document.forms[i]["script_acc" + id + "_off_at"].disabled = disable;
		} catch(e) {}
		
		try { change_type(document.forms[i]["acc" + id + "_type"].value, id); } catch(e) {}
		try { change_registrar(document.forms[i]["acc" + id + "_registrar_active"].value, id); } catch(e) {}
		try { change_mailer(document.forms[i]["script_acc" + id + "_mail_active"].value, id); } catch(e) {}
		try { change_ftp(document.forms[i]["script_acc" + id + "_ftp_active"].value, id); } catch(e) {}
	}
}

function change_type(value, id)
{
	var bDisabled;
	var i;

	bDisabled = true;

	if(value == "voip") 
		bDisabled = false;
	else
		bDisabled = true;

	for(i=0; i<document.forms.length; i++)
	{
		try
		{
			if(document.forms[i]["acc" + id + "_active"].value == '0') {
				bDisabled = true;
			}

			document.forms[i]["acc" + id + "_voip_registrar"].disabled = bDisabled;
			document.forms[i]["acc" + id + "_voip_realm"].disabled = bDisabled;
			document.forms[i]["acc" + id + "_voip_proxy"].disabled = bDisabled;
			document.forms[i]["acc" + id + "_voip_user"].disabled = bDisabled;
			document.forms[i]["acc" + id + "_voip_pass"].disabled = bDisabled;
			document.forms[i]["acc" + id + "_voip_id"].disabled = bDisabled;
			document.forms[i]["acc" + id + "_voip_contact"].disabled = bDisabled;
		} catch(e) {}

	}
}

function change_registrar(value, id)
{
	var bDisabled;	
	var bDisabled2;
	var i;

	bDisabled = true;

	if(value == "1")
		bDisabled = false;
	else
		bDisabled = true;

	for(i=0; i<document.forms.length; i++)
	{
		try
		{		

		if((document.forms[i]["acc" + id + "_active"].value == "0") || (document.forms[i]["acc" + id + "_registrar_active"].value == "0")) {
			bDisabled = true;
		}

		document.forms[i]["acc" + id + "_registrar_user"].disabled = bDisabled;
		document.forms[i]["acc" + id + "_registrar_pass"].disabled = bDisabled;
		} catch(e) {}
	}
}

function change_mailer(value, id)
{
	var bDisabled;
	var i;

	bDisabled = true;

	if(value == "1")
	{
		bDisabled = false;
	}

	for(i=0; i<document.forms.length; i++)
	{
		try
		{	
		document.forms[i]["script_acc" + id + "_mail_from"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_mail_to"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_mail_server"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_mail_user"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_mail_pass"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_mail_delete"].disabled = bDisabled;

		if(!bDisabled) {
			document.forms[i]["script_acc" + id + "_ftp_active"].value = 0;
			change_ftp(0, id);
		}

		} catch(e) {}
	}
}

function change_ftp(value, id)
{
	var bDisabled;
	var i;

	bDisabled = true;

	if(value == "1")
	{
		bDisabled = false;
	}

	for(i=0; i<document.forms.length; i++)
	{
		try
		{
		document.forms[i]["script_acc" + id + "_ftp_server"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_ftp_port"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_ftp_user"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_ftp_pass"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_ftp_path"].disabled = bDisabled;

		if(!bDisabled) {
			document.forms[i]["script_acc" + id + "_mail_active"].value = 0;
			change_mailer(0, id);
		}
		} catch(e) {}
	}
}

function select_script_record()
{
	var i = 0;
	var j = 0;

	for(i=1; i<=10; i++)
	{
		var oSelect = document.getElementById("script_acc" + i + "_record");

		for(j=0; j<oSelect.length; j++)
		{
			if(i==1)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC1_RECORD")
				oSelect.selectedIndex = j;
			if(i==2)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC2_RECORD")
				oSelect.selectedIndex = j;
			if(i==3)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC3_RECORD")
				oSelect.selectedIndex = j;
			if(i==4)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC4_RECORD")
				oSelect.selectedIndex = j;
			if(i==5)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC5_RECORD")
				oSelect.selectedIndex = j;
			if(i==6)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC6_RECORD")
				oSelect.selectedIndex = j;
			if(i==7)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC7_RECORD")
				oSelect.selectedIndex = j;
			if(i==8)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC8_RECORD")
				oSelect.selectedIndex = j;
			if(i==9)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC9_RECORD")
				oSelect.selectedIndex = j;
			if(i==10)
				if(oSelect.options[j].value == "$DTMFBOX_SCRIPT_ACC10_RECORD")
				oSelect.selectedIndex = j;
		}
	}
}
</script>
EOF
fi


# ---------------------------------------------------------------------------------------------
#
# Accounts
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "accounts" ];
then

echo '<a name="accounts" href="#accounts"></a>'
echo '<div id="form_accounts" style="display:block">'

sec_begin 'Accounts'

cat << EOF
<p>
<SELECT NAME='account' onChange='javascript:change_account(value)'>
	<script>
	for(i=1; i<=10; i++)
	{
		document.write("<OPTION VALUE='" + i + "'>" + "Account Nr. " + (i) + "</OPTION>");	
	}
	</script>
</SELECT>
</p>
EOF

# -----------------------
# Accounts (from 1 to 10)
# -----------------------

let i=1
while [ $i -le $MAX_ACCOUNTS ];
do

DTMFBOX_ACC_ACTIVE=`eval echo \"\\$DTMFBOX_ACC${i}_ACTIVE\"`
DTMFBOX_ACC_NAME=`eval echo \"\\$DTMFBOX_ACC${i}_NAME\"`
DTMFBOX_ACC_NUMBER=`eval echo \"\\$DTMFBOX_ACC${i}_NUMBER\"`
DTMFBOX_ACC_TYPE=`eval echo \"\\$DTMFBOX_ACC${i}_TYPE\"`
DTMFBOX_ACC_VOIP_REGISTRAR=`eval echo \"\\$DTMFBOX_ACC${i}_VOIP_REGISTRAR\"`
DTMFBOX_ACC_VOIP_REALM=`eval echo \"\\$DTMFBOX_ACC${i}_VOIP_REALM\"`
DTMFBOX_ACC_VOIP_USER=`eval echo \"\\$DTMFBOX_ACC${i}_VOIP_USER\"`
DTMFBOX_ACC_VOIP_PASS=`eval echo \"\\$DTMFBOX_ACC${i}_VOIP_PASS\"`
DTMFBOX_ACC_VOIP_PROXY=`eval echo \"\\$DTMFBOX_ACC${i}_VOIP_PROXY\"`
DTMFBOX_ACC_VOIP_CONTACT=`eval echo \"\\$DTMFBOX_ACC${i}_VOIP_CONTACT\"`
DTMFBOX_ACC_VOIP_ID=`eval echo \"\\$DTMFBOX_ACC${i}_VOIP_ID\"`
DTMFBOX_ACC_REGISTRAR_ACTIVE=`eval echo \"\\$DTMFBOX_ACC${i}_REGISTRAR_ACTIVE\"`
DTMFBOX_ACC_REGISTRAR_USER=`eval echo \"\\$DTMFBOX_ACC${i}_REGISTRAR_USER\"`
DTMFBOX_ACC_REGISTRAR_PASS=`eval echo \"\\$DTMFBOX_ACC${i}_REGISTRAR_PASS\"`
DTMFBOX_ACC_CTRL_OUT=`eval echo \"\\$DTMFBOX_ACC${i}_CTRL_OUT\"`
DTMFBOX_ACC_DDI=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_DDI\"`
if [ "$DTMFBOX_ACC_DDI" = "" ]; then DTMFBOX_ACC_DDI="**##${i}"; fi
if [ "$DTMFBOX_ACC_ACTIVE" = "1" ]; then voip_acc_active='selected'; else voip_acc_active=''; fi
if [ "$DTMFBOX_ACC_TYPE" = "voip" ]; then voip_acc_type='selected'; else voip_acc_type=''; fi
if [ "$DTMFBOX_ACC_REGISTRAR_ACTIVE" = "1" ]; then voip_reg_active='selected'; else voip_reg_active=''; fi
if [ "$DTMFBOX_VOIP_REGISTRAR" = "0" ]; then DTMFBOX_REGISTRAR_INFO="<b><font color='red' size='1'>Registrar-Modus ist nicht aktiv!</font></b>"; else DTMFBOX_REGISTRAR_INFO=""; fi

cat << EOF

	<!-- Account ${i} -->
	<div id='Acc_${i}' style='display:none'>
	<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td style="background-color:#dddddd"><b>Allgemein</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border='0' cellpadding='0' cellspacing='0' width='$TABLE_WIDTH'>
	<tr><td width="175">Aktiv: </td><td><select id='acc${i}_active' name='acc${i}_active' onchange='javascript:change_active(this.value, ${i})' value='$DTMFBOX_ACC_ACTIVE'><option value='0'>Nein</option><option value='1' $voip_acc_active>Ja</option></select></td></tr>
	<tr><td width="175">Name: </td><td><input id='acc${i}_name' type='text' name='acc${i}_name' size='50' maxlength='255' value='$DTMFBOX_ACC_NAME'></td></tr>
	<tr><td width="175">MSN, Nr.: </td><td><input id='acc${i}_number' type='text' name='acc${i}_number' size='50' maxlength='255' value='$DTMFBOX_ACC_NUMBER' onchange='this.value=this.value.replace(/\\\#/g, "#");this.value=this.value.replace(/#/g, "\\\#");'></td></tr>
	<tr><td width="175">DDI: </td><td><input id='script_acc${i}_ddi' type='text' name='script_acc${i}_ddi' size='10' maxlength='10' value='$DTMFBOX_ACC_DDI'></td></tr>
	<tr><td width="175">CAPI-Ctrl. (ausgehend): </td><td><input id='acc${i}_ctrl_out' type='text' name='acc${i}_ctrl_out' size='2' maxlength='1' value='$DTMFBOX_ACC_CTRL_OUT'></td></tr>
	<tr><td width="175">Type: </td><td><select id='acc${i}_type' name='acc${i}_type' value='$DTMFBOX_ACC_TYPE' onchange="javascript:change_type(this.value, ${i})"><OPTION value='capi'>CAPI</OPTION><OPTION value='voip' $voip_acc_type>SIP</OPTION></SELECT></td></tr>
	</table><br>

	<!-- VoIP settings -->	
	<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td style="background-color:#dddddd"><b>VoIP</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border='0' cellpadding='0' cellspacing='0' width='$TABLE_WIDTH'>
	<tr><td width="175">Registrar: </td><td><input id='acc${i}_voip_registrar' type='text' name='acc${i}_voip_registrar' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_REGISTRAR'></td></tr>
	<tr><td width="175">Realm: </td><td><input id='acc${i}_voip_realm' type='text' name='acc${i}_voip_realm' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_REALM'></td></tr>
	<tr><td width="175">Username: </td><td><input id='acc${i}_voip_user' type='text' name='acc${i}_voip_user' size='25' maxlength='255' value='$DTMFBOX_ACC_VOIP_USER'></td></tr>
	<tr><td width="175">Passwort: </td><td><input id='acc${i}_voip_pass' type='password' name='acc${i}_voip_pass' size='25' maxlength='255' value='$DTMFBOX_ACC_VOIP_PASS'></td></tr>
	<tr><td width="175">Proxy: </td><td><input id='acc${i}_voip_proxy' type='text' name='acc${i}_voip_proxy' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_PROXY'> <font size='1'>(optional)</font></td></tr>
	<tr><td width="175">Contact: </td><td><input id='acc${i}_voip_contact' type='text' name='acc${i}_voip_contact' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_CONTACT'> <font size='1'>(optional)</font></td></tr>
	<tr><td width="175">ID: </td><td><input id='acc${i}_voip_id' type='text' name='acc${i}_voip_id' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_ID'> <font size='1'>(optional)</font></td></tr>
	</table><br>

	<!-- Registrar settings -->
	<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td style="background-color:#dddddd"><b>Registrar-Login</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border='0' cellpadding='0' cellspacing='0' width='$TABLE_WIDTH'>
	<tr><td width="175">Aktiv: </td><td><select id='acc${i}_registrar_active' name='acc${i}_registrar_active' onchange='javascript:change_registrar(this.value, ${i})' value='$DTMFBOX_ACC_REGISTRAR_ACTIVE'><option value='0'>Nein</option><option value='1' $voip_reg_active>Ja</option></select></td></tr>
	<tr><td width="175">Username: </td><td><input id='acc${i}_registrar_user' type='text' name='acc${i}_registrar_user' size='25' maxlength='255' value='$DTMFBOX_ACC_REGISTRAR_USER'></td></tr>
	<tr><td width="175">Passwort: </td><td><input id='acc${i}_registrar_pass' type='password' name='acc${i}_registrar_pass' size='25' maxlength='255' value='$DTMFBOX_ACC_REGISTRAR_PASS'></td></tr>	
	<tr><td colspan='2'>$DTMFBOX_REGISTRAR_INFO</td></tr>
	</table><br>
	</div>

EOF
let i=i+1
done

sec_end

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'

fi



# ---------------------------------------------------------------------------------------------
#
# Anrufbeantworter
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "am" ];
then

echo '<a name="am" href="#am"></a>'
echo '<div id="form_am" style="display:block">'

sec_begin 'Anrufbeantworter'

cat << EOF
<p>
<SELECT NAME='account' onChange='javascript:change_account(value)'>
	<script>
		for(i=1; i<=10; i++)
		{
			document.write("<OPTION VALUE='" + i + "'>" + "Account Nr. " + (i) + "</OPTION>");
		}
	</script>
</SELECT>
</p>
EOF

let i=1
while [ $i -le $MAX_ACCOUNTS ];
do

DTMFBOX_ACC_ACTIVE=`eval echo \"\\$DTMFBOX_ACC${i}_ACTIVE\"`
DTMFBOX_ACC_NUMBER=`eval echo \"\\$DTMFBOX_ACC${i}_NUMBER\"`

if [ "$DTMFBOX_ACC_ACTIVE" = "1" ] && [ "$DTMFBOX_ACC_NUMBER" != "" ];
then

DTMFBOX_SCRIPT_ACC_AM=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_AM\"`
DTMFBOX_SCRIPT_ACC_AM_PIN=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_AM_PIN\"`
DTMFBOX_SCRIPT_ACC_RECORD=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_RECORD\"`
DTMFBOX_SCRIPT_ACC_TIMEOUT=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_TIMEOUT\"`
DTMFBOX_SCRIPT_ACC_RINGTIME=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_RINGTIME\"`
DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_ANNOUNCEMENT\"`
DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT_END=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_ANNOUNCEMENT_END\"`
DTMFBOX_SCRIPT_ACC_UNKNOWN_ONLY=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_UNKNOWN_ONLY\"`
DTMFBOX_SCRIPT_ACC_BEEP=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_BEEP\"`
DTMFBOX_SCRIPT_ACC_ON_AT=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_ON_AT\"`
DTMFBOX_SCRIPT_ACC_OFF_AT=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_OFF_AT\"`
DTMFBOX_SCRIPT_ACC_MAIL_ACTIVE=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_MAIL_ACTIVE\"`
DTMFBOX_SCRIPT_ACC_MAIL_FROM=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_MAIL_FROM\"`
DTMFBOX_SCRIPT_ACC_MAIL_TO=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_MAIL_TO\"`
DTMFBOX_SCRIPT_ACC_MAIL_SERVER=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_MAIL_SERVER\"`
DTMFBOX_SCRIPT_ACC_MAIL_USER=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_MAIL_USER\"`
DTMFBOX_SCRIPT_ACC_MAIL_PASS=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_MAIL_PASS\"`
DTMFBOX_SCRIPT_ACC_MAIL_DELETE=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_MAIL_DELETE\"`
DTMFBOX_SCRIPT_ACC_FTP_ACTIVE=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_FTP_ACTIVE\"`
DTMFBOX_SCRIPT_ACC_FTP_USER=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_FTP_USER\"`
DTMFBOX_SCRIPT_ACC_FTP_PASS=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_FTP_PASS\"`
DTMFBOX_SCRIPT_ACC_FTP_SERVER=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_FTP_SERVER\"`
DTMFBOX_SCRIPT_ACC_FTP_PORT=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_FTP_PORT\"`
DTMFBOX_SCRIPT_ACC_FTP_PATH=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_FTP_PATH\"`

if [ "$DTMFBOX_ACC_ACTIVE" = "1" ]; then voip_acc_active='selected'; else voip_acc_active=''; fi
if [ "$DTMFBOX_SCRIPT_ACC_AM" = "1" ]; then script_acc_am='selected'; else script_acc_am=''; fi
if [ "$DTMFBOX_SCRIPT_ACC_BEEP" = "1" ]; then voip_acc_beep='selected'; else voip_acc_beep=''; fi
if [ "$DTMFBOX_SCRIPT_ACC_MAIL_ACTIVE" = "1" ]; then script_mail='selected'; else script_mail=''; fi
if [ "$DTMFBOX_SCRIPT_ACC_MAIL_DELETE" = "1" ]; then script_mail_delete='selected'; else script_mail_delete=''; fi
if [ "$DTMFBOX_SCRIPT_ACC_FTP_ACTIVE" = "1" ]; then script_ftp_active='selected'; else script_ftp_active=''; fi
if [ "$DTMFBOX_SCRIPT_ACC_UNKNOWN_ONLY" = "1" ]; then script_unknown_only='selected'; else script_unknown_only=''; fi
if [ "$DTMFBOX_SCRIPT_ACC_UNKNOWN_ONLY" = "2" ]; then script_unknown_only2='selected'; else script_unknown_only2=''; fi
let no=i-1

cat << EOF

	<!-- Account ${i} -->
	<div id='Acc_${i}' style='display:none'>
	
	<!-- AB settings -->
	<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td style="background-color:#dddddd"><b>$DTMFBOX_ACC_NUMBER</b></td> <td style="background-color:#dddddd"><div align='right'><b><input type='button' value='Aufnahmen' onclick="javascript:location.href='${SCRIPT_NAME}?pkg=dtmfbox&current_page=am_recordings&show=am_recordings&acc=${i}'" style='border: 1px solid gray; font-size:11px; font-family:trebuchet ms, helvetica, sans-serif; width:75px; height:20px'></b></div></td></tr>
	<tr><td height='5'></td></tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td width="200">Aktiv: </td><td><select id='script_acc${i}_am' name='script_acc${i}_am' onchange='javascript:change_active(this.value, ${i})' value='$DTMFBOX_SCRIPT_ACC_AM'><option value='0'>Nein</option><option value='1' $script_acc_am>Ja</option></select></td></tr>
	<tr><td width="200">Pincode: </td><td> <input id='script_acc${i}_am_pin' type='password' name='script_acc${i}_am_pin' size='5' maxlength='255' value='$DTMFBOX_SCRIPT_ACC_AM_PIN'>#</td></tr>
	<tr><td width="200">Aufnahmezeit: </td><td> <input id="script_acc${i}_timeout" type="text" name="script_acc${i}_timeout" size=5 style='text-align:right' value='$DTMFBOX_SCRIPT_ACC_TIMEOUT'> sec</td></tr>
	<tr><td width="200">Abhebezeit: </td><td> <input id="script_acc${i}_ringtime" type="text" name="script_acc${i}_ringtime" size=5 style='text-align:right' value='$DTMFBOX_SCRIPT_ACC_RINGTIME'> sec</td></tr>
	<tr><td width="200">Ansage: </td>  <td> <input id='script_acc${i}_announcement' type='text' name='script_acc${i}_announcement' size='50' maxlength='255' value='$DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT'> <font size='1'>(Pfad oder URL)</font></td></tr>
	<tr><td width="200">Endansage: </td><td> <input id='script_acc${i}_announcement_end' type='text' name='script_acc${i}_announcement_end' size='50' maxlength='255' value='$DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT_END'> <font size='1'>(Pfad oder URL)</font></td></tr>
	<tr><td width="200">Piepton nach Ansage: </td><td><select id='script_acc${i}_beep' name='script_acc${i}_beep' value='$DTMFBOX_SCRIPT_ACC_BEEP'><option value='0'>Nein</option><option value='1' $voip_acc_beep>Ja</option></select></td></tr>
	<tr><td width="200">Aufnahmemodus: </td><td> <select id='script_acc${i}_record' name='script_acc${i}_record' value='$DTMFBOX_SCRIPT_ACC_RECORD'><OPTION value='ON'>Aufnahme sofort</OPTION><OPTION value='LATER'>Aufnahme nach Ansage</OPTION><OPTION value='OFF'>Aus (nur Ansage/keine Aufnahme)</OPTION></SELECT> </td></tr>
	<tr><td width="200">Abhebemodus: </td><td><select id='script_acc${i}_unknown_only' name='script_acc${i}_unknown_only' value='$DTMFBOX_SCRIPT_UNKNOWN_ONLY'><option value='0'>Alle Anrufer</option><option value='1' $script_unknown_only>Nur unbekannte Anrufer</option><option value='2' $script_unknown_only2>Unbekannte sofort, mit Nr. nach Abhebezeit</option></select></td></tr>
	<tr><td width="200">Schedule: </td><td> <input id="script_acc${i}_on_at" type="text" name="script_acc${i}_on_at" value='$DTMFBOX_SCRIPT_ACC_ON_AT' style='text-align:center' size=4> Uhr anschalten <input id="script_acc${i}_off_at" type="text" name="script_acc${i}_off_at" style='text-align:center' value='$DTMFBOX_SCRIPT_ACC_OFF_AT' size=3> Uhr ausschalten</td></tr>
	</table><br>

	<!-- Mailer settings -->
	<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td style="background-color:#dddddd"><b>Aufnahmen per eMail versenden</b></td> </tr><tr><td height='5'></td></tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">
	<tr><td width="200">Mailversand: </td><td><select id='script_acc${i}_mail_active' name='script_acc${i}_mail_active' onchange='javascript:change_mailer(this.value, ${i})' value='$DTMFBOX_SCRIPT_ACC_MAIL_ACTIVE'><OPTION value='0'>Nein</OPTION><OPTION value='1' $script_mail>Ja</OPTION></SELECT> <font size='1'>(wenn kein USB vorhanden ist = Ja)</font></td></tr>
	<tr><td width="200">eMail Absender:</td><td><input id="script_acc${i}_mail_from" type="text" name="script_acc${i}_mail_from" value='$DTMFBOX_SCRIPT_ACC_MAIL_FROM' size=50></td></tr>
	<tr><td width="200">eMail Empfänger: </td><td> <input id="script_acc${i}_mail_to" type="text" name="script_acc${i}_mail_to" value='$DTMFBOX_SCRIPT_ACC_MAIL_TO' size=50></td></tr>
	<tr><td width="200">SMTP Server:</td><td><input id="script_acc${i}_mail_server" type="text" name="script_acc${i}_mail_server" value='$DTMFBOX_SCRIPT_ACC_MAIL_SERVER' size=50></td></tr>
	<tr><td width="200">Username:</td><td><input id="script_acc${i}_mail_user" type="text" name="script_acc${i}_mail_user" value='$DTMFBOX_SCRIPT_ACC_MAIL_USER' size=50></td></tr>
	<tr><td width="200">Passwort:</td><td><input id="script_acc${i}_mail_pass" type="password" name="script_acc${i}_mail_pass" value='$DTMFBOX_SCRIPT_ACC_MAIL_PASS' size=50></td></tr>
	<tr><td width="200">Löschen nach Versand: </td><td><select id='script_acc${i}_mail_delete' name='script_acc${i}_mail_delete' value='$DTMFBOX_SCRIPT_ACC_MAIL_DELETE'><OPTION value='0'>Nein</OPTION><OPTION value='1' $script_mail_delete>Ja</OPTION></SELECT> <font size='1'>(wenn kein USB vorhanden ist = Ja)</font></td></tr>
	</table><br>

	<!-- Streamer settings -->
	<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td style="background-color:#dddddd"><b>Aufnahmen auf FTP-Server ablegen</b></td> </tr><tr><td height='5'></td></tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">
	<tr><td width="200">FTP Streaming: </td><td><select id='script_acc${i}_ftp_active' name='script_acc${i}_ftp_active' onchange='javascript:change_ftp(this.value, ${i})' value='$DTMFBOX_SCRIPT_ACC_FTP_ACTIVE'><OPTION value='0'>Nein</OPTION><OPTION value='1' $script_ftp_active>Ja</OPTION></SELECT> </td></tr>
	<tr><td width="200">FTP Server & Port:</td><td><input id="script_acc${i}_ftp_server" type="text" name="script_acc${i}_ftp_server" value='$DTMFBOX_SCRIPT_ACC_FTP_SERVER' size=50> <input id="script_acc${i}_ftp_port" type="text" name="script_acc${i}_ftp_port" value='$DTMFBOX_SCRIPT_ACC_FTP_PORT' size=4></td></tr>
	<tr><td width="200">Remote-Pfad: </td><td><input id="script_acc${i}_ftp_path" type="text" name="script_acc${i}_ftp_path" value='$DTMFBOX_SCRIPT_ACC_FTP_PATH' size=50></td></tr>
	<tr><td width="200">Username: </td><td> <input id="script_acc${i}_ftp_user" type="text" name="script_acc${i}_ftp_user" value='$DTMFBOX_SCRIPT_ACC_FTP_USER' size=50></td></tr>
	<tr><td width="200">Passwort: </td><td> <input id="script_acc${i}_ftp_pass" type="password" name="script_acc${i}_ftp_pass" value='$DTMFBOX_SCRIPT_ACC_FTP_PASS' size=50></td></tr>
	</table><br>
	</div>

EOF
else
	echo "<div id='Acc_${i}' style='display:none'>"
	echo "<font color='red'><b>Account deaktiviert!</b></font>"
	echo "</div>"
fi

let i=i+1

done
sec_end

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'
fi


# ---------------------------------------------------------------------------------------------
#
# Callback & Callthrough
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "cbct" ];
then

echo '<a name="cbct" href="#dtmf"></a>'
echo '<div id="form_cbct" style="display:block">'

sec_begin 'Callback & Callthrough'

cat << EOF
<script>
function change_cbct_active(value, id)
{
	var bDisabled;
	var i;

	bDisabled = true;

	if(value == "1")
		bDisabled = false;
	else
		bDisabled = true;

	for(i=0; i<document.forms.length; i++)
	{
		try
		{
		document.forms[i]["script_acc" + id + "_cbct_type"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_cbct_triggerno"].disabled = bDisabled;
		document.forms[i]["script_acc" + id + "_cbct_pincode"].disabled = bDisabled;
		} catch(e) {}
	}
}
</script>

<p>
<SELECT NAME='account' onChange='javascript:change_account(value)'>
	<script>
		for(i=1; i<=10; i++)
		{
			document.write("<OPTION VALUE='" + i + "'>" + "Account Nr. " + (i) + "</OPTION>");
		}
	</script>
</SELECT>
</p>
EOF

let i=1
while [ $i -le $MAX_ACCOUNTS ];
do

DTMFBOX_ACC_ACTIVE=`eval echo \"\\$DTMFBOX_ACC${i}_ACTIVE\"`
if [ "$DTMFBOX_ACC_ACTIVE" = "1" ];
then

DTMFBOX_ACC_NAME=`eval echo \"\\$DTMFBOX_ACC${i}_NAME\"`
DTMFBOX_ACC_NUMBER=`eval echo \"\\$DTMFBOX_ACC${i}_NUMBER\"`
DTMFBOX_ACC_TYPE=`eval echo \"\\$DTMFBOX_ACC${i}_TYPE\"`
DTMFBOX_ACC_CBCT_ACTIVE=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_CBCT_ACTIVE\"`
DTMFBOX_ACC_CBCT_TYPE=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_CBCT_TYPE\"`
DTMFBOX_ACC_CBCT_TRIGGERNO=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_CBCT_TRIGGERNO\"`
DTMFBOX_ACC_CBCT_PINCODE=`eval echo \"\\$DTMFBOX_SCRIPT_ACC${i}_CBCT_PINCODE\"`
if [ "$DTMFBOX_ACC_CBCT_TYPE" = "ct" ]; then ct_selected='selected'; else ct_selected=''; fi
if [ "$DTMFBOX_ACC_CBCT_ACTIVE" = "0" ]; then cbct_active='selected'; else cbct_active=''; fi
let no=i-1

cat << EOF

	<!-- Account ${i} -->
	<div id='Acc_${i}' style='display:none'>
	
	<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
	<tr><td style="background-color:#dddddd"><b>$DTMFBOX_ACC_NUMBER</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border="0">
	<tr>
	<td width="175">Aktiv:</td>
	<td><select id="script_acc${i}_cbct_active" name="script_acc${i}_cbct_active" onchange="change_cbct_active(this.value, ${i});"><option value="1">Ja</option><option value="0" $cbct_active>Nein</option></select></td>
	</tr>

	<tr>
	<td width="175">Callback / Callthrough:</td>
	<td><select id="script_acc${i}_cbct_type" name="script_acc${i}_cbct_type"><option value="cb">Callback</option><option value="ct" $ct_selected>Callthrough</option></select></td>
	</tr>
	
	<tr>
	<td valign="top">Trigger-Nr.:</td>
	<td><input type="text" style="width:350px" id="script_acc${i}_cbct_triggerno" name="script_acc${i}_cbct_triggerno" value="$DTMFBOX_ACC_CBCT_TRIGGERNO"></td>
	</tr>
	
	<tr>
	<td>Pincode:</td>
	<td><input type="password" style="width:50px" id="script_acc${i}_cbct_pincode" name="script_acc${i}_cbct_pincode" value="$DTMFBOX_ACC_CBCT_PINCODE">#</td>
	</tr>
	</table>
	</div>

EOF

else
echo "<div id='Acc_${i}' style='display:none'>"
echo "<font color='red'><b>Account deaktiviert!</b></font>"
echo "</div>"
fi

let i=i+1
done
sec_end


echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'
fi

# ---------------------------------------------------------------------------------------------
#
# DTMF-Commands
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "dtmf" ];
then

echo '<a name="dtmf" href="#dtmf"></a>'
echo '<div id="form_dtmf" style="display:block">'

sec_begin 'DTMF-Commands'

cat << EOF
<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>Account 1 bis 10</b></td></tr><tr><td height='5'</td></tr>
</table>
<br>
<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">
<tr><td><b>Pincode: </b> <input id="script_pincode" style="text-align:right;" type="password" name="script_pincode" size=5 value='$DTMFBOX_SCRIPT_PINCODE'>#</td></tr>
</table>
<p>

<script language="javascript">
function dtmf_change(obj)
{
	var input = obj;
	var cmd = input.value;

	cmd = cmd.replace(/\'\\\'\'/gi, "'");
	cmd = cmd.replace(/'/gi, "\'\\\'\'");
	input.value = cmd;
}
</script>

<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">
EOF

let i=1
while [ $i -le $MAX_DTMFS ];
do
USERCMD=`eval echo \"\\$DTMFBOX_SCRIPT_CMD_${i}\"`

cat << EOF
<tr><td><b><label>$i # </label></b></td><td><textarea style="height:20px;" rows=1 cols=50 id="script_cmd_$i" type="text" name="script_cmd_$i" onchange='javascript:dtmf_change(this);'>$USERCMD</textarea></td></tr>
EOF

let i=i+1

done
cat << EOF
</table>

<!-- escape "'" ! -->
<script>
for(j=1; j<=$MAX_DTMFS; j++) {
	for(i=0; i<document.forms.length; i++) {
		try {
			dtmf_change(document.forms[i]['script_cmd_' + j]);
		} catch(e) {}
	}
}
</script>

</p>
EOF

sec_end

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'

fi

# ---------------------------------------------------------------------------------------------
#
# VoIP-, CAPI-Einstellungen
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "voip_capi" ];
then

voip_chk='';
voip_registrar_chk='';
voip_use_vad='';
voip_ice='';
capi_use_earlyb3='';
capi_display_text='';
espeak_online='';
espeak_installed='';
espeak_found='0';
espeak_voice='';
espeak_vt1='';espeak_vt2='';espeak_vt3='';espeak_vt4='';espeak_vt5='';

if [ "$DTMFBOX_VOIP" = "1" ]; then voip_chk='selected'; else voip_chk=''; fi
if [ "$DTMFBOX_VOIP_REGISTRAR" = "1" ]; then voip_registrar_chk='selected'; fi
if [ "$DTMFBOX_VOIP_USE_VAD" = "1" ]; then voip_use_vad='selected'; fi
if [ "$DTMFBOX_VOIP_ICE" = "1" ]; then voip_ice='selected'; else voip_ice=''; fi
if [ "$DTMFBOX_CAPI_FAKED_EARLYB3" = "1" ]; then capi_use_earlyb3='selected'; else capi_use_earlyb3=''; fi
if [ "$DTMFBOX_CAPI_DISPLAY_TEXT" = "1" ]; then capi_display_text='selected'; else capi_display_text=''; fi

if [ "$DTMFBOX_ESPEAK" = "1" ]; then espeak_online='selected'; else espeak_online=''; fi
if [ "$DTMFBOX_ESPEAK" = "2" ]; then espeak_installed='selected'; else espeak_installed=''; fi
if [ "$DTMFBOX_ESPEAK_VOICE" = "f" ]; then espeak_voice='selected'; fi
if [ "$DTMFBOX_ESPEAK_VOICE_TYPE" = "1" ]; then espeak_vt1='selected'; fi
if [ "$DTMFBOX_ESPEAK_VOICE_TYPE" = "2" ]; then espeak_vt2='selected'; fi
if [ "$DTMFBOX_ESPEAK_VOICE_TYPE" = "3" ]; then espeak_vt3='selected'; fi
if [ "$DTMFBOX_ESPEAK_VOICE_TYPE" = "4" ]; then espeak_vt4='selected'; fi
if [ "$DTMFBOX_ESPEAK_VOICE_TYPE" = "5" ]; then espeak_vt5='selected'; fi
if [ -f "$DTMFBOX_PATH/espeak/speak" ]; then espeak_found="1"; fi
if [ -f "/usr/bin/speak" ]; then espeak_found="1"; fi
if [ "$espeak_found" = "1" ]; then espeak_found="<option value='2' $espeak_installed>eSpeak (Installiert)</option>"; else espeak_found=''; fi

echo '<a name="voip_capi" href="#voip_capi"></a>'
echo '<div id="form_voip_capi" style="display:block">'

sec_begin 'Verbindungseinstellungen'

cat << EOF
<script>
function use_voip(onoff)
{
	var o;
	var i;

	if(onoff == 1)
	{
		o = true;
	}
	else
	{
		o = false;
	}

	for(i=4; i<=18; i++)
	{
		document.getElementById("a" + i).disabled = !o;
	}
}
</script>
<p>

<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>SIP (VoIP)</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">
<tr>
<td width="175">
VoIP verwenden:
</td>
<td>
<select id="a3" name="voip" value='$DTMFBOX_VOIP' onchange="javascript:use_voip(this.value)"><option value='0'>Nein</option><option value='1' $voip_chk>Ja</option></select>
</td>
</tr>

<tr>
<td width="175">
Registrar-Modus:
</td>
<td>
<select id="a7" name="voip_registrar" value='$DTMFBOX_VOIP_REGISTRAR'><option value='0'>Nein</option><option value='1' $voip_registrar_chk>Ja</option></select>
Realm: <input id="a9" type="text" name="voip_realm" value='$DTMFBOX_VOIP_REALM' size=17>
Clients: <input id="a8" type="text" style="text-align:right" name="voip_max_clients" value='$DTMFBOX_VOIP_MAX_CLIENTS' size="1" maxlength="2">
</td>
</tr>

<tr>
<td width="175">
UDP Server Port:
</td>
<td>
<input id="a4" type="text" style="text-align:right" name="voip_udp_port" value='$DTMFBOX_VOIP_UDP_PORT' size="5">
</td>
</tr>

<tr>
<td width="175">
RTP/RTCP Start Port:
</td>
<td>
<input id="a5" type="text" style="text-align:right" name="voip_rtp_start" value='$DTMFBOX_VOIP_RTP_START' size="5">  <font size="1">(20 Verbindungen * 2 Ports = 40 Ports)</font>
</td>
</tr>

<tr>
<td width="175">
Re-Register Intervall:
</td>
<td>
<input id="a14" type="text" style="text-align:right" name="voip_register_interval" value='$DTMFBOX_VOIP_REGISTER_INTERVAL' size="5"> sec
</td>
</tr>

<tr>
<td width="175">
Keep-Alive Intervall:
</td>
<td>
<input id="a15" type="text" style="text-align:right" name="voip_keep_alive" value='$DTMFBOX_VOIP_KEEP_ALIVE' size="5"> sec
</td>
</tr>

<tr>
<td width="175">
VAD (silence detector):
</td>
<td>
<select id="a16" name="voip_use_vad" value='$DTMFBOX_VOIP_USE_VAD'><option value='0'>Nein</option><option value='1' $voip_use_vad>Ja</option></select>
</td>
</tr>

<tr>
<td width="175">
Codec order:
</td>
<td>
<input id="a17" type="text" name="voip_codecs" value='$DTMFBOX_VOIP_CODECS' size="25">
</td>
</tr>

<tr>
<td width="175">
Interface:
</td>
<td>
<input id="a10" type="text" name="voip_ip_addr" value='$DTMFBOX_VOIP_IP_ADDR' size="50">
</td>
</tr>

<tr>
<td width="175">
STUN-Server:
</td>
<td>
<input id="a11" type="text" name="voip_stun" value='$DTMFBOX_VOIP_STUN' size="25"><b>:</b><input id="a12" type="text" style="text-align:right" name="voip_stun_port" value='$DTMFBOX_VOIP_STUN_PORT' size="3" maxlength="5">
ICE: <select id="a13" name="voip_ice" value='$DTMFBOX_VOIP_ICE'><option value='0'>Nein</option><option value='1' $voip_ice>Ja</option></select>
</td>
</tr>

<tr>
<td width="175">
Nameserver:
</td>
<td>
<input id="a18" type="text" name="voip_nameserver" value='$DTMFBOX_VOIP_NAMESERVER' size="50"> <font size='1'>max. 4, Komma getrennt</font>
</td>
</tr>

</table>

<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>CAPI (ISDN/Analog/VoIP)</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">

<tr>
<td width="175">
1. Controller:
</td>
<td>
<input id="a20" type="text" style="text-align:right" name="capi_controller_1" value='$DTMFBOX_CAPI_CONTROLLER_1' size="2" maxlength="1"> <font size="1">(0=OFF, 1=ISDN, 3=Intern, 4=Analog, 5=VoIP)</font>
</td>
</tr>

<tr>
<td width="175">
2. Controller:
</td>
<td>
<input id="a21" type="text" style="text-align:right"  name="capi_controller_2" value='$DTMFBOX_CAPI_CONTROLLER_2' size="2" maxlength="1"> <font size="1">(0=OFF, 1=ISDN, 3=Intern, 4=Analog, 5=VoIP)</font>
</td>
</tr>

<tr>
<td width="175">
3. Controller:
</td>
<td>
<input id="a23" type="text" style="text-align:right"  name="capi_controller_3" value='$DTMFBOX_CAPI_CONTROLLER_3' size="2" maxlength="1"> <font size="1">(0=OFF, 1=ISDN, 3=Intern, 4=Analog, 5=VoIP)</font>
</td>
</tr>

<tr>
<td width="175">
4. Controller:
</td>
<td>
<input id="a24" type="text" style="text-align:right"  name="capi_controller_4" value='$DTMFBOX_CAPI_CONTROLLER_4' size="2" maxlength="1"> <font size="1">(0=OFF, 1=ISDN, 3=Intern, 4=Analog, 5=VoIP)</font>
</td>
</tr>

<tr>
<td width="175">
5. Controller:
</td>
<td>
<input id="a25" type="text" style="text-align:right"  name="capi_controller_5" value='$DTMFBOX_CAPI_CONTROLLER_5' size="2" maxlength="1"> <font size="1">(0=OFF, 1=ISDN, 3=Intern, 4=Analog, 5=VoIP)</font>
</td>
</tr>

<tr>
<td width="175">
Präfix International:
</td>
<td>
<input id="a25" type="text" style="text-align:right"  name="capi_int_prefix" value='$DTMFBOX_CAPI_INT_PREFIX' size="2" maxlength="5"> <font size="1">(Ländercode)</font>
</td>
</tr>

<tr>
<td width="175">
Präfix National:
</td>
<td>
<input id="a26" type="text" style="text-align:right"  name="capi_nat_prefix" value='$DTMFBOX_CAPI_NAT_PREFIX' size="2" maxlength="5"> <font size="1">(Ortsvorwahl ohne führende Null)</font>
</td>
</tr>

<tr>
<td width="175">
Display-Text:
</td>
<td>
<select id="a27" name="capi_display_text" value='$DTMFBOX_CAPI_DISPLAY_TEXT'><option value='0'>Nein</option><option value='1' $capi_display_text>Ja</option></select>
</td>
</tr>
</table>

<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>Audio</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">
<tr>
<td width="175">
Wählton:
</td>
<td>
<select id="a24" name="capi_faked_earlyb3" value='$DTMFBOX_CAPI_FAKED_EARLYB3'><option value='0'>Nein</option><option value='1' $capi_use_earlyb3>Ja</option></select> <font size="1"></font>
</td>
</tr>

<tr>
<td width="175">
RX-Volume:
</td>
<td>
<input id="a29" type="text" name="rx_volume" value='$DTMFBOX_RX_VOLUME' size="2" style="text-align:right" maxlength="3">
</td>
</tr>

<tr>
<td width="175">
TX-Volume:
</td>
<td>
<input id="a30" type="text" name="tx_volume" value='$DTMFBOX_TX_VOLUME' size="2" style="text-align:right" maxlength="3">
</td>
</tr>

<tr>
<td width="175">
EC-Tail Length:
</td>
<td>
<input id="a30" type="text" name="echo_con_tail" value='$DTMFBOX_ECHO_CON_TAIL' size="4" style="text-align:right" maxlength="4"> ms <font size='1'>(0 = off)</font>
</td>
</tr>
</table>

<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>eSpeak (Text-to-Speech)</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" width="$TABLE_WIDTH">
<tr>
<td width="175">
eSpeak:
</td>
<td>
<select id="a28" name="espeak" value='$DTMFBOX_ESPEAK'><option value='0'>Aus (Beep)</option><option value='1' $espeak_online>eSpeak (Web-Stream)</option>$espeak_found</select>
</td>
</tr>

<tr>
<td width="175">
Stimme:
</td>
<td>
<select id="a31" name="espeak_voice" value='$DTMFBOX_ESPEAK_VOICE'><option value='m'>Männlich</option><option value='f' $espeak_voice>Weiblich</option></select>
<select id="a32" name="espeak_voice_type" value='$DTMFBOX_ESPEAK_VOICE_TYPE'><option value='1' $espeak_vt1>1</option><option value='2' $espeak_vt2>2</option><option value='3' $espeak_vt3>3</option><option value='4' $espeak_vt4>4</option><option value='5' $espeak_vt5>mbrola</option></select>
</td>
</tr>

<tr>
<td width="175">
Geschwindigkeit:
</td>
<td>
<input id="a33" type="text" name="espeak_speed" value='$DTMFBOX_ESPEAK_SPEED' size="3" maxlength="3" style='text-align:right'> <font size="1">(150-300)</font>
</td>
</tr>

<tr>
<td width="175">
Pitch:
</td>
<td>
<input id="a34" type="text" name="espeak_pitch" value='$DTMFBOX_ESPEAK_PITCH' size="3" maxlength="2" style='text-align:right'> <font size="1">(0-99)</font>
</td>
</tr>
</table>

<input id="b1" type="hidden" name="voip_client" value='$DTMFBOX_VOIP_CLIENT'>
<input id="b3" type="hidden" name="delimiter" value='$DTMFBOX_DELIMITER'>
<input id="b4" type="hidden" name="scriptfile" value='$DTMFBOX_SCRIPTFILE'>

</p>
<p></p>

EOF

sec_end
echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'
fi


# ---------------------------------------------------------------------------------------------
#
# Sonstiges
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "misc" ];
then

if [ "$DTMFBOX_INFO_CHECKMAILD_FROM" = "1" ]; then checkmaild_from="selected"; fi
if [ "$DTMFBOX_INFO_CHECKMAILD_SUBJECT" = "1" ]; then checkmaild_subject="selected"; fi
if [ -f "$DTMFBOX_INFO_MADPLAY" ]; then madplay_found="<font color='green'>Vorhanden!</font>"; else madplay_found="<font color='red'>madplay nicht vorhanden!</font>"; fi
if [ -f "$DTMFBOX_INFO_MADPLAY" ]; then madplay_found2="<font color='green'>gefunden!</font>"; else madplay_found2="<font color='red'>nicht gefunden!</font>"; fi
if [ -f "$DTMFBOX_INFO_CHECKMAILD/checkmaild.0" ]; then checkmaild_found="<font color='green'>gefunden!</font>"; else checkmaild_found="<font color='red'>nicht gefunden!</font>"; fi

echo '<a name="status" href="#misc"></a>'
echo '<div id="form_misc" style="display:block">'

sec_begin 'Sonstiges'

cat << EOF

<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>(1) Fritz!Box</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="$TABLE_WIDTH">
<tr>
<td>-</td>
</tr>
</table>
</p>

<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>(2) Wetter</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="$TABLE_WIDTH">
<tr>
<td width="150">PLZ:</td><td><input id="weather1" type="text" name="info_weather_plz" value='$DTMFBOX_INFO_WEATHER_PLZ' size="5" maxlength="5"></td>
</tr><tr>
<td width="150">Richtung:</td><td><input id="weather2" type="text" name="info_weather_pos" value='$DTMFBOX_INFO_WEATHER_POS' size="5" maxlength="1" onchange='this.value=this.value.toLowerCase();this.value=this.value.replace(/[^nosw]/g, "")'> <font size='1'>(N)orden, (O)sten, (S)üden, (W)esten</font></td>
</tr><tr>
<td width="150">Podcast:</td><td>$madplay_found</td>
</tr>
</table>
<p></p>

<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>(3) CheckmailD</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="$TABLE_WIDTH">
<tr>
<td width="150">Pfad zu checkmaild.x:</td><td><input id="checkmaild" type="text" name="info_checkmaild" value='$DTMFBOX_INFO_CHECKMAILD' size="50"> <font size='1'>$checkmaild_found</font></td>
</tr><tr>
<td width="150">Absender anzeigen:</td><td><select name="info_checkmaild_from" value='$DTMFBOX_INFO_CHECKMAILD_FROM'><option value="0">Nein</option><option value="1" $checkmaild_from>Ja</option></select></td>
</tr><tr>
<td width="150">Betreff anzeigen:</td><td><select name="info_checkmaild_subject" value='$DTMFBOX_INFO_CHECKMAILD_SUBJECT'><option value="0">Nein</option><option value="1" $checkmaild_subject>Ja</option></select></td>
</tr>
</table>
<p></p>

<p>
<table border="0" cellpadding="3" cellspacing="0" width="$TABLE_WIDTH" bordercolor="darkgray">
<tr><td style="background-color:#dddddd"><b>(4) Radio</b></td></tr><tr><td height='5'</td></tr>
</table>
<table border="0" cellpadding="1" cellspacing="0" width="$TABLE_WIDTH">
<tr>
<td width="150">madplay (Pfad/Datei):</td><td><input id="madplay" type="text" name="info_madplay" value='$DTMFBOX_INFO_MADPLAY' size="50"> <font size='1'>$madplay_found2</font></td>
</tr><tr>
<td width="150">Stream 1:</td><td><input type="text" name="info_madplay_stream1" value='$DTMFBOX_INFO_MADPLAY_STREAM1' size="50"></td>
</tr><tr>
<td width="150">Stream 2:</td><td><input type="text" name="info_madplay_stream2" value='$DTMFBOX_INFO_MADPLAY_STREAM2' size="50"></td>
</tr><tr>
<td width="150">Stream 3:</td><td><input type="text" name="info_madplay_stream3" value='$DTMFBOX_INFO_MADPLAY_STREAM3' size="50"></td>
</tr><tr>
<td width="150">Stream 4:</td><td><input type="text" name="info_madplay_stream4" value='$DTMFBOX_INFO_MADPLAY_STREAM4' size="50"></td>
</tr><tr>
<td width="150">Stream 5:</td><td><input type="text" name="info_madplay_stream5" value='$DTMFBOX_INFO_MADPLAY_STREAM5' size="50"></td>
</tr>
</table>
<p></p>

EOF

sec_end
echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'
fi

# ---------------------------------------------------------------------------------------------
#
# WebPhone
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "webphone" ];
then
echo '<a name="webphone" href="#webphone"></a>'
echo '<div id="form_webphone" style="display:block">'

GLOBAL_IP=`showdsldstat | grep '0: ip' |  sed -r 's/.*ip.(.*)\/.*mtu.*/\1/g'`
let LOC_RTP_START=$DTMFBOX_VOIP_RTP_START+20*2
let LOC_RTCP_START=$LOC_RTP_START+1
let REM_RTP_START=$LOC_RTP_START+2
let REM_RTCP_START=$LOC_RTP_START+3


echo "$RTP_START"
if [ ! -z `pidof dtmfbox` ];
then
	dtmfbox_running="1"
else
	dtmfbox_running="0"
fi

sec_begin 'WebPhone'

cat << EOF
<script>
function change_webphone_account(acc_idx) 
{
	var opt=document.getElementById('account_value_' + (acc_idx+1)); 
	if(opt.text.indexOf('(capi) - ') != -1 ) { 
		document.getElementById('capi_controller').style.display='block'; 
	} else { 
		document.getElementById('capi_controller').style.display='none'; 
	}
}

function webphone_dial()
{
	var	trg_no = document.getElementById('trg_no');
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
	
	
	url = 'dtmfbox.cgi?pkg=dtmfbox&close=1&command=true&script=/bin/sh%20dtmfbox_webphone.cgi%20CALL%20${REMOTE_ADDR}%20$LOC_RTP_START%20$REM_RTP_START%20' + escape(dtmfbox_path) + '%20' + escape(account.value) + '%20' + escape(trg_no.value) + '%20' + escape(controller_value)
	win = window.open(url);
}

function webphone_hangup()
{
	var	trg_no = document.getElementById('trg_no');
	var account =  document.getElementById('account');
	var controller = document.getElementById('selected_controller');
	var dtmfbox_path="$DTMFBOX_PATH";

	win = window.open('dtmfbox.cgi?pkg=dtmfbox&close=1&command=true&script=/bin/sh%20dtmfbox_webphone.cgi%20HANGUP%20${REMOTE_ADDR}%20$LOC_RTP_START%20$REM_RTP_START%20' + escape(dtmfbox_path) + '%20' + escape(account.value) + '%20' + escape(trg_no.value));
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
	<applet code="WebPhone" archive="sWebPhone.jar" codebase="$WEBPHONE_CODEBASE" HEIGHT="0" WIDTH="0">	
	<PARAM NAME="remote_addr" VALUE="${GLOBAL_IP}">
	<PARAM NAME="remote_addr2" VALUE="192.168.178.1">
	<PARAM NAME="remote_addr3" VALUE="169.254.2.1">
	<PARAM NAME="remote_addr4" VALUE="127.0.0.1">
	<PARAM NAME="remote_rtp" VALUE="$REM_RTP_START">
	<PARAM NAME="remote_rtcp" VALUE="$REM_RTCP_START">
	<PARAM NAME="local_rtp" VALUE="$LOC_RTP_START">
	<PARAM NAME="local_rtcp" VALUE="$LOC_RTCP_START">
</applet>
<br>
<table border="0" width="$TABLE_WIDTH">
<tr><td>Account:</td>
<td>
	<select name="account" id="account" onchange="javascript:change_webphone_account(this.selectedIndex)">
EOF

let i=1
let cnt=1
while [ $i -le $MAX_ACCOUNTS ];
do
DTMFBOX_ACC_ACTIVE=`eval echo \"\\$DTMFBOX_ACC${i}_ACTIVE\"`
if [ "$DTMFBOX_ACC_ACTIVE" = "1" ];
then
	DTMFBOX_ACC_NUMBER=`eval echo \"\\$DTMFBOX_ACC${i}_NUMBER\"`
	DTMFBOX_ACC_TYPE=`eval echo \"\\$DTMFBOX_ACC${i}_TYPE\"`
    DTMFBOX_ACC_NUMBER=`echo "$DTMFBOX_ACC_NUMBER" | sed -e 's/\\\#/#/g'`
	echo "<option name=\"account_value_$cnt\" id=\"account_value_$cnt\" value=\"$DTMFBOX_ACC_NUMBER\">($DTMFBOX_ACC_TYPE) - $DTMFBOX_ACC_NUMBER</option>"
	let cnt=cnt+1
fi
let i=i+1
done

cat << EOF	
	</select>
</td>
</tr><tr>
<td>Outgoing Controller:</td>
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
<td>Nr.:</td>
<td>
<input type="text" name="trg_no" id="trg_no">
<input type="button" value="Wählen" onclick="javascript:webphone_dial()">
<input type="button" value="Auflegen"  onclick="javascript:webphone_hangup()">
</td>
</tr></table>

<script>
	change_webphone_account(0);
</script>
EOF
echo '<br>'

# STATUS:
echo "<br><hr color='black'>"
echo "<div name='status'>"
echo "<iframe src=\"./dtmfbox_status.cgi\" width='$TABLE_WIDTH' height='200' frameborder='0' scrolling='horizontal'></iframe>"
echo "</div>"
echo "<br><hr color='black'>"
echo '<br><br><br>'

else
echo "<font style='color:red'><b><i>dtmfbox not running!</i></b></font>"
fi

sec_end
echo '</div>'
echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
fi

# ---------------------------------------------------------------------------------------------
#
# Status
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "status" ];
then

echo '<a name="status" href="#status"></a>'
echo '<div id="form_status" style="display:block">'

# Start-Mode
auto_chk=''; man_chk=''
if [ "$DTMFBOX_ENABLED" = "yes" ]; then auto_chk='checked'; else man_chk='checked'; fi
if [ "$DTMFBOX_ADJUST_PRIORITY" = "1" ]; then adjust_priority='selected'; else adjust_priority=''; fi

# recordings...
if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi

status_recordings=""
let acc_no=1;
while [ $acc_no -le 10 ];
do

let msg_cnt=0;
for file in `find $DTMFBOX_PATH/record/${acc_no}/*`
do
	if [ ! -d $file ]; then
		let msg_cnt=msg_cnt+1
	fi
done

if [ "$msg_cnt" != "0" ];
then
	DTMFBOX_ACC_ACTIVE=`eval echo \"\\$DTMFBOX_ACC${acc_no}_ACTIVE\"`
	DTMFBOX_ACC_NUMBER=`eval echo \"\\$DTMFBOX_ACC${acc_no}_NUMBER\"`

	if [ "$DTMFBOX_ACC_ACTIVE" = "1" ];
	then
		if [ "$acc_no" = "1" ]; then
			status_recordings="<a href='${SCRIPT_NAME}?pkg=dtmfbox&current_page=am_recordings&show=am_recordings&acc=${acc_no}'>Account #${acc_no} ($DTMFBOX_ACC_NUMBER) - $msg_cnt Nachricht(en)"
		else
			status_recordings="$status_recordings<br><a href='${SCRIPT_NAME}?pkg=dtmfbox&current_page=am_recordings&show=am_recordings&acc=${acc_no}'>Account #${acc_no} ($DTMFBOX_ACC_NUMBER) - $msg_cnt Nachricht(en)"
		fi
	
		status_recordings="$status_recordings</a>"	
	fi
fi

let acc_no=$acc_no+1
done

# view log?
if [ -f "$DTMFBOX_PATH/dtmfbox.log" ]; then
	VIEWLOG_CMD="dtmfbox.cgi?pkg=dtmfbox&command=true&script=cat%20$DTMFBOX_PATH/dtmfbox.log&close=0"
	btnViewLog="<td><input type='button' value='Log ansehen' onclick=\"javascript:window.open('$VIEWLOG_CMD');\" id='view_log' name='view_log' style=\"border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;\"></td>"
fi

sec_begin 'Status'

if [ ! -z `pidof dtmfbox` ];
then
status_daemon="running"
else
status_daemon="stopped"
fi

cat << EOF
	<table border="0">
	<tr>
	<td width="150px"><font size="2"><b>Startmodus:</b></font></td>
	<td><input id="a1" type="radio" name="enabled" value="yes" $auto_chk><label for="a1"> Automatisch</label> <input id="a2" type="radio" name="enabled" value="no" $man_chk><label for="a2"> Manuell</label></td>
	</tr>
	<tr>
	<td width="150px"><font size="2"><b>Prozess Priorität:</b></font></td>
	<td><select id='adjust_priority' name='adjust_priority' value='$DTMFBOX_ADJUST_PRIORITY'><option value='0'>Hoch</option><option value='1' $adjust_priority>Auto</option></select></td>
	</tr>
	<tr>
	<td width="150px"><font size="2"><b>Loglevel:</b></font></td>
	<td><input id='a_12' type='text' style='text-align:right' name='loglevel' value='$DTMFBOX_LOGLEVEL' size='2'></td>
	</tr>
	</table>

	<table border="0">
	<tr>
EOF
	
	if [ "$status_daemon" = "running" ];
	then
cat << EOF
		<td width="150"><font size="2" color="green"><i><b>dtmfbox running!</b></i></font></td>
		<td align="center"><input type="button" value="Restart" onclick="javascript:location.href='${SCRIPT_NAME}?pkg=dtmfbox&start=daemon&show=$CURRENT_PAGE'" id="start_daemon" name="start_daemon" style="border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;"></td>
		<td align="center"><input type="button" value="Restart (Log)" onclick="javascript:location.href='${SCRIPT_NAME}?pkg=dtmfbox&start=logged&show=$CURRENT_PAGE'" id="start_logged" name="start_logged" style="border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;"></td>
		<td align="center"><input type="button" value="Stoppen" onclick="javascript:location.href='${SCRIPT_NAME}?pkg=dtmfbox&start=stop&show=$CURRENT_PAGE'" id="stop_daemon" name="stop_daemon" style="border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;"></td>
		$btnViewLog
	</tr>
	</table>
EOF
	else
cat << EOF
		<td width="150"><font size="2" color="red"><i><b>dtmfbox stopped!</b></i></font></td>
		<td align="center"><input type="button" value="Starten" onclick="javascript:location.href='${SCRIPT_NAME}?pkg=dtmfbox&start=daemon&show=$CURRENT_PAGE'" id="start_daemon" name="start_daemon" style="border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;"></td>
		<td align="center"><input type="button" value="Starten (Log)" onclick="javascript:location.href='${SCRIPT_NAME}?pkg=dtmfbox&start=logged&show=$CURRENT_PAGE'" id="start_logged" name="start_logged" style="border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;"></td>
		$btnViewLog
	</tr>
	</table>	
EOF
	fi
cat << EOF
	<pre style="font-size:11px" width="70%">$status_recordings</pre>
EOF

# STATUS:
echo "<div name='status'>"
echo "<iframe src=\"./dtmfbox_status.cgi\" width='$TABLE_WIDTH' height='200' frameborder='0' scrolling='horizontal'></iframe>"
echo "</div>"

echo "<script></script>"

sec_end

sec_begin 'USB-Pfad'

cat << EOF
<p>
<input id="e1" type="text" name="path" value="$DTMFBOX_PATH" size="50" onblur="javascript:got_usb_path.value=path.value; if(path.value != '/var/dtmfbox' && path.value != '') { got_usb.value='1'; } else { got_usb.value='0'; path.value='/var/dtmfbox'; got_usb_path.value='/var/dtmfbox' }"><br>
<font size="1">Leer lassen, falls kein USB!</font><br>
<font size="1">Hier werden die Aufnahmen, Ansagen und Skripte abgelegt.<br>Komplette Pfadangabe!</font><br>
</p>
EOF

sec_end

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('$MAIN_LINK&help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'
fi

# ---------------------------------------------------------------------------------------------
#
# Aufnahmen
#
# ---------------------------------------------------------------------------------------------
if [ "$CURRENT_PAGE" = "am_recordings" ];
then

let ITEMS_PER_PAGE=10

acc_no=`echo ${QUERY_STRING} | sed -n 's/.*acc=\(.*\)/\1/p' | sed -e 's/&.*//g'`
let page=`echo ${QUERY_STRING} | sed -n 's/.*page=\(.*\)/\1/p' | sed -e 's/&.*//g'`
let page=page-1;
if [ $page -le 0 ]; then let page=0; fi

delimiter="\n"
ftp_user=`eval echo "\\$DTMFBOX_SCRIPT_ACC${acc_no}_FTP_USER"`
ftp_pass=`eval echo "\\$DTMFBOX_SCRIPT_ACC${acc_no}_FTP_PASS"`
ftp_path=`eval echo "\\$DTMFBOX_SCRIPT_ACC${acc_no}_FTP_PATH"`
ftp_server=`eval echo "\\$DTMFBOX_SCRIPT_ACC${acc_no}_FTP_SERVER"`
ftp_port=`eval echo "\\$DTMFBOX_SCRIPT_ACC${acc_no}_FTP_PORT"`

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
						cmd_remote="cat << EOF > /var/tmp/nc_ftp_cmd\n$ftp_login";
	
						cmd_remote = cmd_remote + 'DELE ' + document.forms[j]['recfilename' + i].value + '\n';
					}	
				}
			} catch(e) {}
		}
	}
	if(cmd_remote.length > 0) {
		cmd_remote = cmd_remote + "QUIT\nEOF\n";
		cmd_remote = cmd_remote + "cat /var/tmp/nc_ftp_cmd | $NC $ftp_server:$ftp_port;\n"	
		cmd_remote = cmd_remote + "rm /var/tmp/nc_ftp_cmd;\n"	
	}

	if(cmd_local.length > 0)
	{
		cmd_local=escape(cmd_local);
		cmd_remote=escape(cmd_remote);
		this.document.location.href="${SCRIPT_NAME}?pkg=dtmfbox&current_page=am_recordings&show=am_recordings&acc=$acc_no&delete=true&cmd_local=" + cmd_local + "&cmd_remote=" + cmd_remote
	}
}
</script>
EOF

echo '<a name="am_recordings" href="#am_recordings"></a>'
echo '<div id="form_am_recordings" style="display:block">'

sec_begin "Aufnahmen - Account #${acc_no}"

echo "<p></p>"
echo "<table border='0' cellpadding='1' cellspacing='0' width='$TABLE_WIDTH'>"

let rec_no=1
let p=0;
let position=0;
let start_position="$page"
let start_position=start_position*$ITEMS_PER_PAGE;
let end_position=$start_position+$ITEMS_PER_PAGE-1;
for file in `ls -r $DTMFBOX_PATH/record/$acc_no/*`
do

if [ -f $file ]; then

	if [ $position -ge $start_position ] && [ $position -le $end_position ];
	then

	filename=`echo $file | sed 's/^.*\/\(.*\..*\)$/\1/g'`
	FILE_DATE=`echo $filename | sed 's/^\(..\).\(..\).\(..\)--\(..\).\(..\).*$/\3.\2.20\1, \4:\5/g'`
	CALLER_NO=`echo $filename | sed 's/^.*---.*-\(.*\)[\.]...$/\1/g'`
	IS_FTP=`echo $filename | sed 's/^.*\.raw$/FTP/g'`
	let FILE_DURATION=`$DU "$file" | sed -e "s/\([0-9]*\).*/\1/g"`
	let FILE_DURATION=$FILE_DURATION*1024/17500

	if [ "$IS_FTP" != "FTP" ];
	then
	IS_FTP="HDD";
	else
	IS_FTP="FTP";
	fi	

	if [ "$IS_FTP" != "FTP" ]; then
		if [ "$FREETZ" = "0" ]; then
			DOWNLOAD_CMD="dtmfbox_cmd.cgi?script=cat%20$file&binary=true&download_name=$filename"
		else
			DOWNLOAD_CMD="rudi_shellcmd.cgi?display_mode=binary&script=cat%20$file&binary=true&download_name=$filename"
		fi
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
	echo "<td width='55'><div align='right'>$FILE_DURATION sec</div></td>"
	echo "<td width='10'></td>"
	echo "<td>$CALLER_NO</td>"
	echo "<td width='75'><div align='center'><input type='button' value='Anhören' onclick=\"javascript:win=window.open('$DOWNLOAD_CMD');\" style='border: 1px solid gray; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div></td>"
	#echo "<td width='75'><div align='center'><input type='button' value='Löschen' onclick=\"javascript:win=window.open('$DELETE_CMD&script=rm%20$file&filename=$file'); function page_refresh() { location.reload() }; window.setTimeout(page_refresh, 1000);\" style='border: 1px solid gray; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div></td>"
	echo "</tr>"

	let rec_no=rec_no+1;
	let p=p+1;
	if [ $p -eq 2 ]; then p=0; fi
	fi

	let position=position+1;
fi
done

echo "</table>"
echo "<hr color='gray'>"

echo "<table border='0' width='$TABLE_WIDTH' cellpadding='0' cellspacing='0'><tr>"
echo "<td align='left' width='175px'><input type='button' value='Auswahl umkehren' onclick=\"javascript:for(j=0; j<document.forms.length;j++) { for(i=0; i<${rec_no}; i++) { try { document.forms[j]['recording' + i].checked = !document.forms[j]['recording' + i].checked; } catch(e) {} } }\" style='border: 1px solid gray; font-family:trebuchet ms,helvetica,sans-serif;width:150px'></td>"

let pages=$position/$ITEMS_PER_PAGE;
let pages2=$pages*$ITEMS_PER_PAGE;
if [ "$pages2" -ne "$position" ]; then let pages=pages+1; fi

echo "<td align='left'>$position Nachricht(en) - Seite: "
let page=1;
while [ $page -le $pages ];
do
	let p=$page-1;
	echo -n "<a href='?current_page=$CURRENT_PAGE&acc=$acc_no&page=$page'>$page</a>"
	if [ $page -ne $pages ]; then echo -n ", "; fi
	let page=page+1
done
echo "</td>"
echo "<td align='right'><input type='button' value='Löschen' onclick=\"javascript:delete_recordings($rec_no)\" style='border: 1px solid gray; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></td>"
echo "</tr></table>"
sec_end

echo "<p></p><br>"
echo '</div>'

fi

if [ "$CURRENT_PAGE" != "status" ];
then
echo "<input id='path' type='hidden' name='path' value=\"$DTMFBOX_PATH\">"
fi

# --- FORM END ---
frm_end "$package"


if [ "$CURRENT_PAGE" = "userscript" ];
then

# Userdefined script
#
echo '<a name="userscript" href="#userscript"></a>'
echo '<div id="form_userscript" style="display:block">'

sec_begin 'Benutzerdefiniertes Skript'

id="dtmfbox_userscript"
DTMFBOX_FILE="/etc/default.dtmfbox/dtmfbox.file"
CONFIG_FILE="/var/tmp/flash/dtmfbox_userscript.sh"

# Load config
[ -r "$DTMFBOX_FILE" ] && . $DTMFBOX_FILE
[ -r "$CONFIG_FILE" ] && . $CONFIG_FILE
echo "<p>$DESCRIPTION</p>"
echo "<form action=\"/cgi-bin/save.cgi?form=file_$id\" method=\"post\" target='_blank'>"
echo -n '<textarea style="width: $TABLE_WIDTH;" name="content" rows='"$TEXT_ROWS"' cols="60" wrap="off">'
[ -r "$CONFIG_FILE" ] && $HTTPD -e `cat "$CONFIG_FILE"`
echo '</textarea>'
echo '<div class="btn"><input type="submit" value="&Uuml;bernehmen"></div>'
echo '</form>'
echo '<p></p>'

sec_end
echo '</div>'

fi

# --- CGI END ---
cgi_end

cat << EOF
<script>
try
{
	change_account(1);
	select_script_record();
} catch(e) {}

try
{
	use_voip("$DTMFBOX_VOIP");
} catch(e) {}

	try
	{
		if("$CURRENT_PAGE" == "userscript")
		{
			document.getElementById('default').style.display='none';
			document.getElementById('save').style.display='none';
		}
		else
		{	
			document.getElementById('default').style.display='block';
			document.getElementById('save').style.display='block';	
		}
	} catch(e) {}
</script>
EOF
