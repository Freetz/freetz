#!/bin/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox v0.3.9 - dsmod addon (c) 2007 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------
DSMOD="1"
DTMFBOX_VERSION="v0.3.9"
MAX_ACCOUNTS=10             # max. number of accounts: 10
MAX_DTMFS=50                # max. number of dtmf-commands: 50

if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi

# dsmod or mini_httpd ?
if [ "$DSMOD" = "0" ];
then

    # FULLSCREEN
    . ./dtmfbox_lib.cgi
  
	if [ ! -f /var/dtmfbox/dtmfbox.save ]; then
      mkdir /var/dtmfbox 2>/dev/null
      cp ../../default.dtmfbox/dtmfbox.cfg /var/dtmfbox/dtmfbox.save
    fi

    # read config
    . /var/dtmfbox/dtmfbox.save

else
    
    if [ "$DESIGN" != "mod" ]; then

	    # FULLSCREEN
	    . /usr/mww/cgi-bin/dtmfbox_lib.cgi

	else

        # MOD
        . /usr/lib/libmodcgi.sh
        . /usr/lib/libmodfrm.sh
    fi

    # read config
    . /mod/etc/conf/dtmfbox.cfg
fi

if [ "${QUERY_STRING}" != "" ]; then

	# Param: current Page
    if [ "$CURRENT_PAGE" = "" ]; then
  	  CURRENT_PAGE=`echo ${QUERY_STRING} | sed -n 's/.*current_page=\(.*\)/\1/p' | sed -e 's/&.*//g'`    
	fi 

    if [ "$CURRENT_PAGE" = "" ]; 
    then

	# Param: Command
    if [ "$CMD" = "" ]; then
  	  CMD=`echo ${QUERY_STRING} | sed -n 's/.*command=\(.*\)/\1/p' | sed -e 's/&.*//g'`
    fi
	
	# execute a command
	if [ "$CMD" = "true" ]; then  
	
	  # Param: script
	  script=`echo ${QUERY_STRING} | sed -n 's/.*script=\(.*\)/\1/p' | sed -e 's/&.*//' | sed -f /var/tmp/urldecode.sed`
	
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
      echo "if(self.stop)"
      echo "stop();"
      echo "else if(document.execCommand)"
      echo "document.execCommand('Stop');"
      echo "</script>"

	  # alles was danach kommt, weg...
	  echo '<div style="display:none"><textarea>'

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
        if [ "$DSMOD" = "1" ];
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

        if [ "$DSMOD" = "1" ];
        then
 	      /etc/init.d/rc.dtmfbox log > /dev/null
        else
          /var/dtmfbox/rc.dtmfbox log > /dev/null
        fi
	  fi
	
      # Daemon stoppen
	  if [ "$START" = "stop" ]; 
	  then
        if [ "$DSMOD" = "1" ]; 
        then
   	      /etc/init.d/rc.dtmfbox stop > /dev/null
        else
   	      /var/dtmfbox/rc.dtmfbox stop > /dev/null
        fi
	  fi

# relocate
cat << EOF
	  <script>location.href='${SCRIPT_NAME}?pkg=dtmfbox&show=$SHOW';</script>
EOF
	fi

    fi
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
  echo "<input type='hidden' name='got_usb' id='got_usb' value='0'>"
  echo "<input type='hidden' name='got_usb_path' id='got_usb_path' value=\"$DTMFBOX_PATH\">"
else
  echo "<input type='hidden' name='got_usb' id='got_usb' value='1'>"
  echo "<input type='hidden' name='got_usb_path' id='got_usb_path' value=\"$DTMFBOX_PATH\">"
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
		   document.forms[i]["acc" + id + "_msn"].disabled = disable;
		   document.forms[i]["acc" + id + "_type"].disabled = disable;
		   document.forms[i]["acc" + id + "_voip_registrar"].disabled = disable;
		   document.forms[i]["acc" + id + "_voip_realm"].disabled = disable;
		   document.forms[i]["acc" + id + "_voip_proxy"].disabled = disable;
		   document.forms[i]["acc" + id + "_voip_user"].disabled = disable;
		   document.forms[i]["acc" + id + "_voip_pass"].disabled = disable;
		   document.forms[i]["acc" + id + "_voip_id"].disabled = disable;
		   document.forms[i]["acc" + id + "_voip_contact"].disabled = disable;
        } catch(e) {}

	   try
	   {		
		   document.forms[i]["script_acc" + id + "_record"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_timeout"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_ringtime"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_announcement"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_announcement_end"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_beep"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_mail_active"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_mail_from"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_mail_to"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_mail_server"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_mail_user"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_mail_pass"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_mail_delete"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_on_at"].disabled = disable;
		   document.forms[i]["script_acc" + id + "_off_at"].disabled = disable;
	   } catch(e) {}
	
	   if(disable == false)
       {
		   try { change_type(document.forms[i]["acc" + id + "_type"].value, id); } catch(e) {}
		   try { change_mailer(document.forms[i]["script_acc" + id + "_mail_active"].value, id); } catch(e) {}
       }
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
    } catch(e) {}
  }
}

</script>

<script>
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
     if(i==1)
       document.write("<OPTION SELECTED VALUE='" + i + "'>" + "*#10" + (i-1) + "# - Account Nr. " + (i) + "</OPTION>");
     else
       document.write("<OPTION VALUE='" + i + "'>" + "*#10" + (i-1) + "# - Account Nr. " + (i) + "</OPTION>");
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

DTMFBOX_ACC_ACTIVE=`eval echo \\$DTMFBOX_ACC${i}_ACTIVE`
DTMFBOX_ACC_NAME=`eval echo \\$DTMFBOX_ACC${i}_NAME`
DTMFBOX_ACC_MSN=`eval echo \\$DTMFBOX_ACC${i}_MSN`
DTMFBOX_ACC_TYPE=`eval echo \\$DTMFBOX_ACC${i}_TYPE`
DTMFBOX_ACC_VOIP_REGISTRAR=`eval echo \\$DTMFBOX_ACC${i}_VOIP_REGISTRAR`
DTMFBOX_ACC_VOIP_REALM=`eval echo \\$DTMFBOX_ACC${i}_VOIP_REALM`
DTMFBOX_ACC_VOIP_USER=`eval echo \\$DTMFBOX_ACC${i}_VOIP_USER`
DTMFBOX_ACC_VOIP_PASS=`eval echo \\$DTMFBOX_ACC${i}_VOIP_PASS`
DTMFBOX_ACC_VOIP_PROXY=`eval echo \\$DTMFBOX_ACC${i}_VOIP_PROXY`
DTMFBOX_ACC_VOIP_CONTACT=`eval echo \\$DTMFBOX_ACC${i}_VOIP_CONTACT`
DTMFBOX_ACC_VOIP_ID=`eval echo \\$DTMFBOX_ACC${i}_VOIP_ID`
if [ "$DTMFBOX_ACC_ACTIVE" = "1" ]; then voip_acc_active='selected'; else voip_acc_active=''; fi
if [ "$DTMFBOX_ACC_TYPE" = "voip" ]; then voip_acc_type='selected'; else voip_acc_type=''; fi

cat << EOF 

	<!-- Account ${i} -->
	<div id='Acc_${i}' style='display:none'>
	<table border="0" cellpadding="3" cellspacing="0" width="100%" bordercolor="darkgray">
	  <tr><td style="background-color:#dddddd"><b>Allgemein</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border='0' cellpadding='0' cellspacing='0' width='100%'>
	  <tr><td width="200">Aktiv: </td><td><select id='acc${i}_active' name='acc${i}_active' onchange='javascript:change_active(this.value, ${i})' value='$DTMFBOX_ACC_ACTIVE'><option value='0'>Nein</option><option value='1' $voip_acc_active>Ja</option></select></td></tr>
	  <tr><td width="200">Name: </td><td><input id='acc${i}_name' type='text' name='acc${i}_name' size='50' maxlength='255' value='$DTMFBOX_ACC_NAME'></td></tr>
	  <tr><td width="200">MSN: </td><td><input id='acc${i}_msn' type='text' name='acc${i}_msn' size='50' maxlength='255' value='$DTMFBOX_ACC_MSN'></td></tr>
	  <tr><td width="200">Type: </td><td><select id='acc${i}_type' name='acc${i}_type' value='$DTMFBOX_ACC_TYPE' onchange="javascript:change_type(this.value, ${i})"><OPTION value='isdn'>ISDN/Analog</OPTION><OPTION value='voip' $voip_acc_type>VoIP</OPTION></SELECT></td></tr>
	</table><br>

	<!-- VoIP settings -->	
	<table border="0" cellpadding="3" cellspacing="0" width="100%" bordercolor="darkgray">
	  <tr><td style="background-color:#dddddd"><b>VoIP</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border='0' cellpadding='0' cellspacing='0' width='100%'>
	  <tr><td width="200">Registrar: </td><td><input id='acc${i}_voip_registrar' type='text' name='acc${i}_voip_registrar' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_REGISTRAR'></td></tr>
	  <tr><td width="200">Realm: </td><td><input id='acc${i}_voip_realm' type='text' name='acc${i}_voip_realm' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_REALM'></td></tr>
	  <tr><td width="200">Username: </td><td><input id='acc${i}_voip_user' type='text' name='acc${i}_voip_user' size='25' maxlength='255' value='$DTMFBOX_ACC_VOIP_USER'></td></tr>
	  <tr><td width="200">Passwort: </td><td><input id='acc${i}_voip_pass' type='password' name='acc${i}_voip_pass' size='25' maxlength='255' value='$DTMFBOX_ACC_VOIP_PASS'></td></tr>
	  <tr><td width="200">Proxy: </td><td><input id='acc${i}_voip_proxy' type='text' name='acc${i}_voip_proxy' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_PROXY'> <font size='1'>(optional)</font></td></tr>
	  <tr><td width="200">Contact: </td><td><input id='acc${i}_voip_contact' type='text' name='acc${i}_voip_contact' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_CONTACT'> <font size='1'>(optional)</font></td></tr>
	  <tr><td width="200">ID: </td><td><input id='acc${i}_voip_id' type='text' name='acc${i}_voip_id' size='50' maxlength='255' value='$DTMFBOX_ACC_VOIP_ID'> <font size='1'>(optional)</font></td></tr>
	</table><br>
	</div>

EOF

let i=i+1

done

sec_end

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('dtmfbox.cgi?help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
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
     if(i==1)
       document.write("<OPTION SELECTED VALUE='" + i + "'>" + "*#10" + (i-1) + "# - Account Nr. " + (i) + "</OPTION>");
     else
       document.write("<OPTION VALUE='" + i + "'>" + "*#10" + (i-1) + "# - Account Nr. " + (i) + "</OPTION>");
   }
   </script>
 </SELECT>
</p>
EOF

let i=1
while [ $i -le $MAX_ACCOUNTS ];
do

DTMFBOX_ACC_ACTIVE=`eval echo \\$DTMFBOX_ACC${i}_ACTIVE`
DTMFBOX_ACC_MSN=`eval echo \\$DTMFBOX_ACC${i}_MSN`

if [ "$DTMFBOX_ACC_ACTIVE" = "1" ] && [ "$DTMFBOX_ACC_MSN" != "" ]; 
then

  DTMFBOX_SCRIPT_ACC_AM=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_AM`
  DTMFBOX_SCRIPT_ACC_RECORD=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_RECORD`
  DTMFBOX_SCRIPT_ACC_TIMEOUT=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_TIMEOUT`
  DTMFBOX_SCRIPT_ACC_RINGTIME=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_RINGTIME`
  DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_ANNOUNCEMENT`
  DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT_END=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_ANNOUNCEMENT_END`
  DTMFBOX_SCRIPT_ACC_BEEP=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_BEEP`
  DTMFBOX_SCRIPT_ACC_ON_AT=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_ON_AT`
  DTMFBOX_SCRIPT_ACC_OFF_AT=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_OFF_AT`
  DTMFBOX_SCRIPT_ACC_MAIL_ACTIVE=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_MAIL_ACTIVE`
  DTMFBOX_SCRIPT_ACC_MAIL_FROM=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_MAIL_FROM`
  DTMFBOX_SCRIPT_ACC_MAIL_TO=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_MAIL_TO`
  DTMFBOX_SCRIPT_ACC_MAIL_SERVER=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_MAIL_SERVER`
  DTMFBOX_SCRIPT_ACC_MAIL_USER=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_MAIL_USER`
  DTMFBOX_SCRIPT_ACC_MAIL_PASS=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_MAIL_PASS`
  DTMFBOX_SCRIPT_ACC_MAIL_DELETE=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_MAIL_DELETE`

  if [ "$DTMFBOX_ACC_ACTIVE" = "1" ]; then voip_acc_active='selected'; else voip_acc_active=''; fi
  if [ "$DTMFBOX_SCRIPT_ACC_AM" = "1" ]; then script_acc_am='selected'; else script_acc_am=''; fi
  if [ "$DTMFBOX_SCRIPT_ACC_BEEP" = "1" ]; then voip_acc_beep='selected'; else voip_acc_beep=''; fi
  if [ "$DTMFBOX_SCRIPT_ACC_MAIL_ACTIVE" = "1" ]; then script_mail='selected'; else script_mail=''; fi
  if [ "$DTMFBOX_SCRIPT_ACC_MAIL_DELETE" = "1" ]; then script_mail_delete='selected'; else script_mail_delete=''; fi
  let no=i-1

cat << EOF 

	<!-- Account ${i} -->
	<div id='Acc_${i}' style='display:none'>
	
	<!-- AB settings -->
	<table border="0" cellpadding="3" cellspacing="0" width="100%" bordercolor="darkgray">
	  <tr><td style="background-color:#dddddd"><b>*#10${no}# - $DTMFBOX_ACC_MSN</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%" bordercolor="darkgray">
	  <tr><td width="200">Aktiv: </td><td><select id='script_acc${i}_am' name='script_acc${i}_am' onchange='javascript:change_active(this.value, ${i})' value='$DTMFBOX_SCRIPT_ACC_AM'><option value='0'>Nein</option><option value='1' $script_acc_am>Ja</option></select></td></tr>
	  <tr><td width="200">Aufnahmemodus: </td><td> <select id='script_acc${i}_record' name='script_acc${i}_record' value='$DTMFBOX_SCRIPT_ACC_RECORD'><OPTION value='ON'>An (Aufnahme sofort)</OPTION><OPTION value='LATER'>Later (Aufnahme nach Ansage)</OPTION><OPTION value='OFF'>Aus (nur Ansage)</OPTION></SELECT> </td></tr>
	  <tr><td width="200">Aufnahmezeit: </td><td> <input id="script_acc${i}_timeout" type="text" name="script_acc${i}_timeout" size=5 value='$DTMFBOX_SCRIPT_ACC_TIMEOUT'> sec</td></tr>
	  <tr><td width="200">Abhebezeit: </td><td> <input id="script_acc${i}_ringtime" type="text" name="script_acc${i}_ringtime" size=5 value='$DTMFBOX_SCRIPT_ACC_RINGTIME'> sec</td></tr>
	  <tr><td width="200">Ansage: </td>  <td> <input id='script_acc${i}_announcement' type='text' name='script_acc${i}_announcement' size='50' maxlength='255' value='$DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT'></td></tr>
	  <tr><td width="200">Endansage: </td><td> <input id='script_acc${i}_announcement_end' type='text' name='script_acc${i}_announcement_end' size='50' maxlength='255' value='$DTMFBOX_SCRIPT_ACC_ANNOUNCEMENT_END'></td></tr>
	  <tr><td width="200">Piepton nach Ansage: </td><td><select id='script_acc${i}_beep' name='script_acc${i}_beep' value='$DTMFBOX_SCRIPT_ACC_BEEP'><option value='0'>Nein</option><option value='1' $voip_acc_beep>Ja</option></select></td></tr>
	  <tr><td width="200">Schedule: </td><td> <input id="script_acc${i}_on_at" type="text" name="script_acc${i}_on_at" value='$DTMFBOX_SCRIPT_ACC_ON_AT' size=4> Uhr anschalten <input id="script_acc${i}_off_at" type="text" name="script_acc${i}_off_at" value='$DTMFBOX_SCRIPT_ACC_OFF_AT' size=3> Uhr ausschalten</td></tr>
	</table><br>

	<!-- Mailer settings -->
	<table border="0" cellpadding="3" cellspacing="0" width="100%" bordercolor="darkgray">
	  <tr><td style="background-color:#dddddd"><b>eMail-Versand</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
	  <tr><td width="200">Mailversand: </td><td><select id='script_acc${i}_mail_active' name='script_acc${i}_mail_active' onchange='javascript:change_mailer(this.value, ${i})' value='$DTMFBOX_SCRIPT_ACC_MAIL_ACTIVE'><OPTION value='0'>Nein</OPTION><OPTION value='1' $script_mail>Ja</OPTION></SELECT> <font size='1'>(wenn kein USB vorhanden ist = Ja)</font></td></tr>
	  <tr><td width="200">eMail Absender:</td><td><input id="script_acc${i}_mail_from" type="text" name="script_acc${i}_mail_from" value='$DTMFBOX_SCRIPT_ACC_MAIL_FROM' size=50></td></tr>
	  <tr><td width="200">eMail Empfänger: </td><td> <input id="script_acc${i}_mail_to" type="text" name="script_acc${i}_mail_to" value='$DTMFBOX_SCRIPT_ACC_MAIL_TO' size=50></td></tr>
	  <tr><td width="200">SMTP Server:</td><td><input id="script_acc${i}_mail_server" type="text" name="script_acc${i}_mail_server" value='$DTMFBOX_SCRIPT_ACC_MAIL_SERVER' size=50></td></tr>
	  <tr><td width="200">Username:</td><td><input id="script_acc${i}_mail_user" type="text" name="script_acc${i}_mail_user" value='$DTMFBOX_SCRIPT_ACC_MAIL_USER' size=50></td></tr>
	  <tr><td width="200">Passwort:</td><td><input id="script_acc${i}_mail_pass" type="password" name="script_acc${i}_mail_pass" value='$DTMFBOX_SCRIPT_ACC_MAIL_PASS' size=50></td></tr>
	  <tr><td width="200">Löschen nach Versand: </td><td><select id='script_acc${i}_mail_delete' name='script_acc${i}_mail_delete' value='$DTMFBOX_SCRIPT_ACC_MAIL_DELETE'><OPTION value='0'>Nein</OPTION><OPTION value='1' $script_mail_delete>Ja</OPTION></SELECT> <font size='1'>(wenn kein USB vorhanden ist = Ja)</font></td></tr>
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

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('dtmfbox.cgi?help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
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
<p>
 <SELECT NAME='account' onChange='javascript:change_account(value)'>
   <script>
   for(i=1; i<=10; i++)
   {
     if(i==1)
       document.write("<OPTION SELECTED VALUE='" + i + "'>" + "*#10" + (i-1) + "# - Account Nr. " + (i) + "</OPTION>");
     else
       document.write("<OPTION VALUE='" + i + "'>" + "*#10" + (i-1) + "# - Account Nr. " + (i) + "</OPTION>");
   }
   </script>
 </SELECT>
</p>
EOF

let i=1
while [ $i -le $MAX_ACCOUNTS ];
do

DTMFBOX_ACC_ACTIVE=`eval echo \\$DTMFBOX_ACC${i}_ACTIVE`
if [ "$DTMFBOX_ACC_ACTIVE" = "1" ]; 
then

DTMFBOX_ACC_NAME=`eval echo \\$DTMFBOX_ACC${i}_NAME`
DTMFBOX_ACC_MSN=`eval echo \\$DTMFBOX_ACC${i}_MSN`
DTMFBOX_ACC_TYPE=`eval echo \\$DTMFBOX_ACC${i}_TYPE`
DTMFBOX_ACC_CBCT_TYPE=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_CBCT_TYPE`
DTMFBOX_ACC_CBCT_TRIGGERNO=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_CBCT_TRIGGERNO`
DTMFBOX_ACC_CBCT_PINCODE=`eval echo \\$DTMFBOX_SCRIPT_ACC${i}_CBCT_PINCODE`
if [ "$DTMFBOX_ACC_CBCT_TYPE" = "ct" ]; then ct_selected='selected'; else ct_selected=''; fi
let no=i-1

cat << EOF

	<!-- Account ${i} -->
	<div id='Acc_${i}' style='display:none'>
	
	<table border="0" cellpadding="3" cellspacing="0" width="100%" bordercolor="darkgray">
	   <tr><td style="background-color:#dddddd"><b>*#10${no}# - $DTMFBOX_ACC_MSN</b></td></tr><tr><td height='5'</td></tr>
	</table>
	<table border="0">
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

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('dtmfbox.cgi?help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
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
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr><td><b>Admin-Pincode: </b> <input id="script_pincode" style="text-align:right;" type="password" name="script_pincode" size=5 value='$DTMFBOX_SCRIPT_PINCODE'>#</td></tr>
</table>
<p>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
EOF

let i=1
while [ $i -le $MAX_DTMFS ];
do
     
  USERCMD=`eval echo \\$DTMFBOX_SCRIPT_CMD_${i}`

cat << EOF
  <tr><td><b><label>* $i # </label></b></td><td><input id="script_cmd_$i" type="text" name="script_cmd_$i" value='$USERCMD' size=70></td></tr>
EOF

  let i=i+1

done

cat << EOF
</table>
</p>
EOF

sec_end

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('dtmfbox.cgi?help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
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
capi_use_earlyb3=''

if [ "$DTMFBOX_VOIP" = "1" ]; then voip_chk='selected'; else voip_chk=''; fi
if [ "$DTMFBOX_VOIP_REGISTRAR" = "1" ]; then voip_registrar_chk='selected'; fi
if [ "$DTMFBOX_VOIP_USE_VAD" = "1" ]; then voip_use_vad='selected'; fi
if [ "$DTMFBOX_VOIP_ICE" = "1" ]; then voip_ice='selected'; else voip_ice=''; fi
if [ "$DTMFBOX_CAPI_FAKED_EARLYB3" = "1" ]; then capi_use_earlyb3='selected'; else capi_use_earlyb3=''; fi

echo '<a name="voip_capi" href="#voip_capi"></a>'
echo '<div id="form_voip_capi" style="display:block">'

sec_begin ''

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

 	 for(i=4; i<=16; i++)
 	 {
	   document.getElementById("a" + i).disabled = !o;
	 }
  }

</script>

<p>
<table border="0" cellpadding="0" cellspacing="0" width="100%">

<font size="3"><b>VoIP (SIP)</b></font><br><br>

<tr>
<td>
  VoIP verwenden:
</td>
<td>
  <select id="a3" name="voip" value='$DTMFBOX_VOIP' onchange="javascript:use_voip(this.value)"><option value='0'>Nein</option><option value='1' $voip_chk>Ja</option></select>
</td>
</tr>

<tr>
<td>
  UDP Server Port:
</td>
<td>
  <input id="a4" type="text" style="text-align:right" name="voip_udp_port" value='$DTMFBOX_VOIP_UDP_PORT' size="5">
</td>
</tr>

<tr>
<td>
  RTP/RTCP Start Port:
</td>
<td>
  <input id="a5" type="text" style="text-align:right" name="voip_rtp_start" value='$DTMFBOX_VOIP_RTP_START' size="5">
  Anzahl: <input id="a6" type="text" style="text-align:right" name="voip_rtp_ports" value='$DTMFBOX_VOIP_RTP_PORTS' size="2">
</td>
</tr>

<tr>
<td>
  Registrar-Modus:
</td>
<td>
  <select id="a7" name="voip_registrar" value='$DTMFBOX_VOIP_REGISTRAR'><option value='0'>Nein</option><option value='1' $voip_registrar_chk>Ja</option></select>
  Clients: <input id="a8" type="text" style="text-align:right" name="voip_max_clients" value='$DTMFBOX_VOIP_MAX_CLIENTS' size="2">
</td>
</tr>

<tr>
<td>
  Realm:
</td>
<td>
  <input id="a9" type="text" name="voip_realm" value='$DTMFBOX_VOIP_REALM' size=50>
</td>
</tr>

<tr>
<td>
  Interface:
</td>
<td>
  <input id="a10" type="text" name="voip_ip_addr" value='$DTMFBOX_VOIP_IP_ADDR' size=50>
</td>
</tr>

<tr>
<td>
  STUN-Server:
</td>
<td>
  <input id="a11" type="text" name="voip_stun" value='$DTMFBOX_VOIP_STUN' size=42> 
  <input id="a12" type="text" style="text-align:right" name="voip_stun_port" value='$DTMFBOX_VOIP_STUN_PORT' size="3">
</td>
</tr>

<tr>
<td>
  ICE:
</td>
<td>
  <select id="a13" name="voip_ice" value='$DTMFBOX_VOIP_ICE'><option value='0'>Nein</option><option value='1' $voip_ice>Ja</option></select>
</td>
</tr>

<tr>
<td>
  Re-Register Intervall:
</td>
<td>
  <input id="a14" type="text" style="text-align:right" name="voip_register_interval" value='$DTMFBOX_VOIP_REGISTER_INTERVAL' size="5"> sec
</td>
</tr>

<tr>
<td>
  Keep-Alive Intervall:
</td>
<td>
  <input id="a15" type="text" style="text-align:right" name="voip_keep_alive" value='$DTMFBOX_VOIP_KEEP_ALIVE' size="5"> sec
</td>
</tr>

<tr>
<td>
  VAD (silence detector):
</td>
<td>
  <select id="a16" name="voip_use_vad" value='$DTMFBOX_VOIP_USE_VAD'><option value='0'>Nein</option><option value='1' $voip_use_vad>Ja</option></select>
</td>
</tr>

<tr><td colspan="2"><br><font size="3"><b>CAPI (ISDN/Analog)</b></font><br><br></td></tr>

<tr>
<td>
  Controller (eingehend):
</td>
<td>
  <input id="a20" type="text" style="text-align:right" name="capi_incoming" value='$DTMFBOX_CAPI_INCOMING' size="2"> <font size="1">(0=NOT USED, 1=ISDN, 2=ISDN, 3=Internal, 4=Analog)</font>
</td>
</tr>

<tr>
<td>
  Controller (ausgehend):
</td>
<td>
  <input id="a21" type="text" style="text-align:right"  name="capi_outgoing" value='$DTMFBOX_CAPI_OUTGOING' size="2"> <font size="1">(0=NOT USED, 1=ISDN, 2=ISDN, 3=Internal, 4=Analog)</font>
</td>
</tr>

<tr>
<td>
  Controller (intern):
</td>
<td>
  <input id="a23" type="text" style="text-align:right"  name="capi_internal" value='$DTMFBOX_CAPI_INTERNAL' size="2"> <font size="1">(0=NOT USED, 1=ISDN, 2=ISDN, 3=Internal, 4=Analog)</font>
</td>
</tr>

<tr>
<td>
  Early B3:
</td>
<td>
  <select id="a24" name="capi_faked_earlyb3" value='$DTMFBOX_CAPI_FAKED_EARLYB3'><option value='0'>Nein</option><option value='1' $capi_use_earlyb3>Ja</option></select> <font size="1">(Wählton)</font>
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
echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('dtmfbox.cgi?help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'

fi

#if [ "$CURRENT_PAGE" = "usb" ];
#then
#echo '<a name="usb" href="#usb"></a>'
#echo '<div id="form_usb" style="display:block">'
#echo '</div>'
#fi

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

# recordings...
if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
status_recordings="<table border='0' cellpadding='0' cellspacing='0' width='100%'>"
for file in `find $DTMFBOX_PATH/record/* 2>/dev/null`
do

  filename=`echo $file | sed -e 's/^.*\/\(.*\..*\)$/\1/g'`

  if [ "$DSMOD" = "0" ]; then
    DOWNLOAD_CMD="dtmfbox_cmd.cgi?"
    DELETE_CMD="dtmfbox.cgi?pkg=dtmfbox&command=true&close=1&"
  else
    DOWNLOAD_CMD="rudi_shellcmd.cgi?display_mode=binary"
    DELETE_CMD="dtmfbox.cgi?pkg=dtmfbox&command=true&close=1&"
  fi

  if [ ! -d $file ]; then
    status_recordings="$status_recordings <tr>"
    status_recordings="$status_recordings <td><input type='button' value='$filename' onclick=\"javascript:win=window.open('$DOWNLOAD_CMD&script=cat%20$file&binary=true&download_name=$filename');\"  style=\"border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;width:380px\"></td>"
    status_recordings="$status_recordings <td><input type='button' value='löschen' onclick=\"javascript:win=window.open('$DELETE_CMD&script=rm%20$file&filename=$file'); function page_refresh() { location.reload() }; window.setTimeout(page_refresh, 1000);\" style=\"border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;\"></td>"
    status_recordings="$status_recordings </tr>"
  fi
done
status_recordings="$status_recordings</table>"

# view log?
if [ -f "$DTMFBOX_PATH/dtmfbox.log" ]; then

  if [ "$DSMOD" = "0" ]; then
    VIEWLOG_CMD="dtmfbox_cmd.cgi?script=cat%20$DTMFBOX_PATH/dtmfbox.log"
  else
    VIEWLOG_CMD="dtmfbox.cgi?pkg=dtmfbox&command=true&script=cat%20$DTMFBOX_PATH/dtmfbox.log&close=0"
  fi

  btnViewLog="<td><input type='button' value='Log ansehen' onclick=\"javascript:window.open('$VIEWLOG_CMD');\" id='view_log' name='view_log' style=\"border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;\"></td>"
fi

sec_begin 'Status'

if [ ! -z "$(pidof 'dtmfbox')" ]; 
then
  status_daemon="running" 
else
  status_daemon="stopped"
fi

cat << EOF
	<p></p>
    <font size="2"><b>Startmodus:</b></font> <input id="a1" type="radio" name="enabled" value="yes" $auto_chk><label for="a1"> Automatisch</label> <input id="a2" type="radio" name="enabled" value="no" $man_chk><label for="a2"> Manuell</label>
	<p></p>
    <table border="0" width="100%">
    <tr>
EOF
    
	  if [ "$status_daemon" = "running" ];
      then

cat << EOF
  	  <td width="150"><font size="2" color="green"><i><b>dtmfbox running!</b></i></font></td>
  	  <td align="center"><input type="button" value="Stoppen" onclick="javascript:location.href='${SCRIPT_NAME}?pkg=dtmfbox&start=stop&show=$CURRENT_PAGE'" id="stop_daemon" name="stop_daemon" style="border: 1px solid; font-family:'trebuchet ms',helvetica,sans-serif;"></td>
      $btnViewLog
      </tr>
      </table>
  	  <p></p>
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

    <br>
	<font size="2"><b>Loglevel:</b></font> <input id='a_12' type='text' style='text-align:right' name='loglevel' value='$DTMFBOX_LOGLEVEL' size='2'>
	<p></p>
	
	<font size="2">
	<i><b>Aufnahmen ($DTMFBOX_PATH/record)</b></i><br>
	$status_recordings
	</font>
	<br>
	</p>
EOF
	
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

echo "<br><div align='right'><input type='button' value='Hilfe' onclick=\"javascript:window.open('dtmfbox.cgi?help=$CURRENT_PAGE');\" style='border: 1px solid; font-family:trebuchet ms,helvetica,sans-serif;width:75px'></div>"
echo '</div>'

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
echo -n '<textarea style="width: 100%;" name="content" rows='"$TEXT_ROWS"' cols="60" wrap="off">'
[ -r "$CONFIG_FILE" ] && httpd -e "$(cat $CONFIG_FILE)"
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

if [ "$DESIGN" = "mod" ]; then 
  echo "<div style='display:none'><textarea>"
fi  