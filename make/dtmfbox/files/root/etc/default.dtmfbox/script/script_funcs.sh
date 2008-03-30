#!/var/tmp/sh
##################################################################################
## dtmfbox - global script functions
##################################################################################
EVENT="$1"                    # CONNECT, CONFIRMED, EARLY, DDI, DTMF, DISCONNECT
TYPE="$2"                     # VOIP, CAPI
IN_OUT="$3"                   # INCOMING, OUTGOING
SRC_CON="$4"                  # Source-Connection ID (own ID)
DST_CON="$5"                  # Target-Connection ID (partner)
SRC_NO="$6"                   # Source-No.
DST_NO="$7"                   # Target-No.
ACC_NO="$8"                   # Account No. (1-10)
DTMF="$9"                     # DTMF

##################################################################################
## scriptfiles
##################################################################################
SCRIPT_MAIN="./script/script_main.sh"
SCRIPT_AM="./script/script_am.sh"
SCRIPT_CBCT="./script/script_cbct_call.sh"
SCRIPT_INTERNAL="./script/script_internal.sh"
SCRIPT_INTERNAL_SUB="./script/script_internal"

SCRIPT_SPEAK="./script/script_speak.sh"
SCRIPT_WAITEVENT="./script/script_waitevent.sh"
SCRIPT_CFG_TEMPLATE="./script/script_cfg_template.sh"
SCRIPT_SED="./script/script_sed.sh"

##################################################################################
## required shell commands
##################################################################################
if [ -f /usr/bin/mkfifo ]; then MKFIFO="/usr/bin/mkfifo"; fi
if [ "$MKFIFO" = "" ]; then MKFIFO="./busybox-tools mkfifo"; fi
if [ -f /usr/bin/tee ]; then TEE="/usr/bin/tee"; fi
if [ "$TEE" = "" ]; then TEE="./busybox-tools tee"; fi
if [ -f /usr/bin/head ]; then HEAD="/usr/bin/head"; fi
if [ "$HEAD" = "" ]; then HEAD="./busybox-tools head"; fi
if [ -f /usr/bin/tail ]; then TAIL="/usr/bin/tail"; fi
if [ "$TAIL" = "" ]; then TAIL="./busybox-tools tail"; fi
if [ -f /usr/bin/du ]; then DU="/usr/bin/du"; fi
if [ "$DU" = "" ]; then DU="./busybox-tools du"; fi
if [ -f /usr/bin/nc ]; then NC="/usr/bin/nc"; fi
if [ "$NC" = "" ]; then NC="./busybox-tools nc"; fi
if [ -f /usr/bin/ftpput ]; then FTPPUT="/usr/bin/ftpput"; fi
if [ "$FTPPUT" = "" ]; then FTPPUT="./busybox-tools ftpput"; fi

##################################################################################
## speech text - menue_ansage()
##################################################################################
alias SPEECH_INTERNAL="echo 1 Anrufbeantworter. 2 DTMF Befehle. 3 Koolfruh. 4 Sonstiges."
alias SPEECH_INTERNAL_1="echo Sie haben "
alias SPEECH_INTERNAL_2="echo DTMF Befehle. 1 bis 50."
alias SPEECH_INTERNAL_3="echo Koolfruh."
alias SPEECH_INTERNAL_4="echo 1 Fritz Box. 2 Wetter. 3 scheck maeil. 4 Radio."
alias SPEECH_INTERNAL_4_1="echo 1 Ei,Pi Adresse. 2 letzter Ribuht. 3 Uhrzeit."
alias SPEECH_INTERNAL_4_2="echo 1 Wetter vorher sage. 2 Bieoo wetter. 3 Pod kahst."
alias SPEECH_INTERNAL_4_3="echo Maeilaekaunt 1 bis 3 waehlen."
alias SPEECH_INTERNAL_4_4="echo Radio sztriem 1 bis 5 waehlen."

##################################################################################
## global files
##################################################################################
ACC_CFG="./tmp/dtmfbox_acc${ACC_NO}.cfg"
TEMP_CURSCRIPT="./tmp/$SRC_CON.curscript"

##################################################################################
## Set required variables
##################################################################################
# freetz...
if [ -f /mod/etc/conf/dtmfbox.cfg ]; 
then
  if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
  PATH=$PATH:$DTMFBOX_PATH
  DTMFBOX="dtmfbox"
  DTMFBOX_CFG="/mod/etc/conf/dtmfbox.cfg"
  USERSCRIPT="/var/tmp/flash/dtmfbox_userscript.sh"
  FREETZ="1"
fi

# .. standalone / usb
if [ -f /var/dtmfbox/dtmfbox.save ]; 
then
  if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
  PATH=$PATH:$DTMFBOX_PATH
  DTMFBOX="dtmfbox"
  DTMFBOX_CFG="$DTMFBOX_PATH/dtmfbox.save"
  USERSCRIPT="$DTMFBOX_PATH/script/dtmfbox_userscript.sh"
  FREETZ="0"
fi	

##################################################################################
## execute user-script, if exist ($SCRIPT: BEFORE_LOAD)
##################################################################################
if [ -f "$USERSCRIPT" ]; 
then
	SCRIPT="BEFORE_LOAD"
	. "$USERSCRIPT"
	if [ "$?" = "1" ]; then exit 1; fi
fi

##################################################################################
## Load complete data (!)
##################################################################################
read_main_cfg() {
	. "$DTMFBOX_CFG"
}

##################################################################################
## Load only account specific data
##################################################################################
load_data() {
	if [ -f "$ACC_CFG" ];
	then
		. "$ACC_CFG"
	fi
}

##################################################################################
## Remove temporary data
##################################################################################
remove_data() {
   rm "$TEMP_CURSCRIPT"    2>/dev/null
}

##################################################################################
## Run a dtmfbox command ($1 = con_id, $2 = cmd)
##################################################################################
dtmfbox_cmd() {
  $DTMFBOX $1 $2
}

##################################################################################
## Change scriptfile ($1 = con_id, $2 = scriptfile, $3 = delimiter, $4 = misc)
##################################################################################
dtmfbox_change_script() {

  # change script
  dtmfbox_cmd "$1" "-scriptfile $2 -delimiter $3"
  if [ "$4" != "" ]; then dtmfbox_cmd "$1" "$4"; fi

  # save scriptfile name
  echo "$2" > "$TEMP_CURSCRIPT"

  # call "STARTUP" event in script (when available)
  . "$2" "STARTUP" "$TYPE" "$IN_OUT" "$SRC_CON" "$DST_CON" "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF"
}

##################################################################################
## Play a tone ($1 = "" (stop), "ok", "notok", "beep", "freeline", "busy")
##################################################################################
play_tone() {

  case "$1" in
      "")
        $DTMFBOX $SRC_CON -stop tone
      ;;
	  "ok")
        $DTMFBOX $SRC_CON -tone 400 400 250 2000 32767; 
        $DTMFBOX $SRC_CON -tone 800 800 250 2000 32767; 
        sleep 1;
        $DTMFBOX $SRC_CON -stop tone
      ;;
	  "notok")
        $DTMFBOX $SRC_CON -tone 800 800 250 2000 32767; 
        $DTMFBOX $SRC_CON -tone 400 400 250 2000 32767; 
        sleep 1;
        $DTMFBOX $SRC_CON -stop tone
      ;;
	  "beep")
        $DTMFBOX $SRC_CON -tone 800 800 1000 1000 32767; 
        sleep 1; 
        $DTMFBOX $SRC_CON -stop tone
      ;;
	  "freeline")
	    $DTMFBOX $SRC_CON -tone 425 425 1000 0 32767
      ;;
	  "busy")
        $DTMFBOX $SRC_CON -tone 425 425 480 480 32767
      ;;
	  "short-busy")
        $DTMFBOX $SRC_CON -tone 425 425 480 480 32767; 
        sleep 2; 
        $DTMFBOX $SRC_CON -stop tone
      ;;
      esac
}

##################################################################################
## text2speech or beep. $1=Text, $2=[1|0] (1=beep notok), $3=1 (ignore eSpeak)
##################################################################################
say_or_beep() {
   . "$SCRIPT_SPEAK" "$1" "$2" "$3"
}

##################################################################################
## Function to display a text (CAPI). $1=Text, $2="" or "SCROLL", $3=timeout
##################################################################################
display_text() {

  # display-text active?
  if [ "$DTMFBOX_CAPI_DISPLAY_TEXT" = "0" ]; then return 1; fi

  # no display-text, when there are more DTMF characters in queue (fast typing)
  WAITING_EVENTS=`$HEAD -n 1 "./tmp/$SRC_CON.waitevent-file"`
  if [ "$WAITING_EVENTS" != "" ]; then return 1; fi

  TEXT="$1"
  SUB_CMD="$2"
  SLEEP_TIME="$3"
  if [ "$SLEEP_TIME" = "" ]; then SLEEP_TIME="2"; fi

  # with scrolling
  if [ "$SUB_CMD" = "SCROLL" ];
  then
    let cnt=0
    for WORD in $TEXT
    do
      if [ "$cnt" = "0" ]; then W1="$WORD"; fi
      if [ "$cnt" = "1" ]; then W2="$WORD"; fi
      if [ "$cnt" = "2" ]; then W3="$WORD"; fi

      let cnt=cnt+1
      if [ "$cnt" = "3" ];
      then
        $DTMFBOX $SRC_CON -text "$W1 $W2 $W3"
        sleep $SLEEP_TIME

        W1=""; W2=""; W3="";
        let cnt=0;
      fi
    done
    $DTMFBOX $SRC_CON -text "$W1 $W2 $W3"
    sleep $SLEEP_TIME

  # without scrolling
  else
    $DTMFBOX $SRC_CON -text "$TEXT"
    sleep $SLEEP_TIME
  fi

}

##################################################################################
## save settings (freetz or usb), "$1" = key, "$2" = value
##################################################################################
save_settings() {

   DTMFBOX_SETTINGS_KEY="$1"
   DTMFBOX_SETTINGS_VAL="$2"

   # save usb/standalone
   if [ "$FREETZ" = "0" ];
   then
     cat "$DTMFBOX_CFG"  | sed "s/export $DTMFBOX_SETTINGS_KEY='\(.*\)'/export $DTMFBOX_SETTINGS_KEY='$DTMFBOX_SETTINGS_VAL'/g" > $DTMFBOX_PATH/tmp/cfg1.tmp
     cat "$DTMFBOX_BOOT" | sed "s/export $DTMFBOX_SETTINGS_KEY='\(.*\)'/export $DTMFBOX_SETTINGS_KEY='$DTMFBOX_SETTINGS_VAL'/g" > $DTMFBOX_PATH/tmp/cfg2.tmp
     if [ -f $DTMFBOX_PATH/tmp/cfg1.tmp ] && [ -f $DTMFBOX_PATH/tmp/cfg2.tmp ]; then 
       cat $DTMFBOX_PATH/tmp/cfg1.tmp > $DTMFBOX_CFG
       cat $DTMFBOX_PATH/tmp/cfg2.tmp > $DTMFBOX_BOOT
       chmod +x $DTMFBOX_CFG
       chmod +x $DTMFBOX_BOOT
       rm $DTMFBOX_PATH/tmp/cfg1.tmp 2>/dev/null
       rm $DTMFBOX_PATH/tmp/cfg2.tmp 2>/dev/null
     fi

   # save freetz
   else

     modconf set dtmfbox "$DTMFBOX_SETTINGS_KEY=$DTMFBOX_SETTINGS_VAL"
     modconf save dtmfbox
     modsave

   fi
}

##################################################################################
## Function to call at disconnect ($1="1": remove global data)
##################################################################################
disconnect() {
  . "$SCRIPT_WAITEVENT" "STOP"
  remove_data
}

##################################################################################
## Global events (read/load/remove data)
##################################################################################
if [ "$EVENT" != "DDI" ];
then
  load_data
fi

if [ "$EVENT" = "DISCONNECT" ];
then
  disconnect
fi

##################################################################################
## Important! When listening on CAPI Controller 5, reject first connect!!!!
## Otherwise there will be a fallback to ISDN/Analog.
##################################################################################
if [ "$EVENT" = "CONNECT" ] && [ "$TYPE" = "CAPI" ] && [ "$IN_OUT" = "OUTGOING" ] && [ "$DST_NO" = "unknown" ] && [ "$ACC_CTRL_OUT" = "5" ];
then
  $DTMFBOX $SRC_CON -hook reject  
  exit 1
fi

##################################################################################
## execute user-script, if exist ($SCRIPT: FUNCS)
##################################################################################
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="FUNCS"
  . "$USERSCRIPT"
  if [ "$?" = "1" ]; then exit 1; fi
fi
