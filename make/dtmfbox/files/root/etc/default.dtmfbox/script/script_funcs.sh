#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - script funcs 
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# Load configuration
# --------------------------------------------------------------------------------
# dsmod ..
if [ -f /mod/etc/conf/dtmfbox.cfg ]; 
then
  . /mod/etc/conf/dtmfbox.cfg

  if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
  DTMFBOX="dtmfbox"
  DTMFBOX_CFG="/mod/etc/conf/dtmfbox.cfg"
  USERSCRIPT="/var/tmp/flash/dtmfbox_userscript.sh"
  if [-f "$DTMFBOX_PATH/script/dtmfbox_userscript.sh" ]; then 
    USERSCRIPT="$DTMFBOX_PATH/script/dtmfbox_userscript.sh"
  fi
  DSMOD="1"
fi

# .. standalone
if [ -f /var/dtmfbox/dtmfbox.save ]; 
then
  . /var/dtmfbox/dtmfbox.save

  if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
  DTMFBOX="$DTMFBOX_PATH/dtmfbox"
  DTMFBOX_CFG="/var/dtmfbox/dtmfbox.save"
  USERSCRIPT="$DTMFBOX_PATH/script/dtmfbox_userscript.sh"
  if [ -f "/var/dtmfbox/boot.cfg" ]; 
  then
    DTMFBOX_BOOT="/var/dtmfbox/boot.cfg"
  else
    DTMFBOX_BOOT="/var/flash/debug.cfg"
  fi

  DSMOD="0"
fi

# got USB?
if [ "$DTMFBOX_PATH" = "/var/dtmfbox" ]; then GOT_USB="0"; else GOT_USB="1"; fi

# no configuration? abort!
if [ ! -f /mod/etc/conf/dtmfbox.cfg ] && [ ! -f /var/dtmfbox/dtmfbox.save ]; then
  echo "script_funcs.sh : configuration not found!"
  echo "                  dsmod: /mod/etc/conf/dtmfbox.cfg"
  echo "                  usb:   /var/dtmfbox/dtmfbox.save"
  return 1;
fi

# --------------------------------------------------------------------------------
# Parameter
# --------------------------------------------------------------------------------
EVENT="$1"                    # CONNECT, CONFIRMED, DDI, DTMF, DISCONNECT
TYPE="$2"                     # VOIP, CAPI
IN_OUT="$3"                   # INCOMING, OUTGOING
SRC_CON="$4"                  # Source-Connection ID (own ID)
DST_CON="$5"                  # Target-Connection ID (partner)
SRC_NO="$6"                   # Source-No.
DST_NO="$7"                   # Target-No.
ACC_NO="$8"                   # Account No. (1-10)
DTMF="$9"                     # DTMF

# global status files
CURSCRIPT="$DTMFBOX_PATH/tmp/current_script_$SRC_CON.tmp"
CURACCOUNT="$DTMFBOX_PATH/tmp/current_account_$SRC_CON.tmp"
CURCALLBACK="$DTMFBOX_PATH/tmp/current_cb_account_$SRC_CON.tmp"
PINFILE_DTMF="$DTMFBOX_PATH/tmp/script_dtmf_pin_$SRC_CON.tmp"
TALKING="/var/tmp/$SRC_CON-espeak.talking"

# scripts
ADMINSCRIPT="$DTMFBOX_PATH/script/script_admin.sh"
AMSCRIPT="$DTMFBOX_PATH/script/script_am_admin.sh"
DTMFSCRIPT="$DTMFBOX_PATH/script/script_dtmf.sh"
CBCTSCRIPT="$DTMFBOX_PATH/script/script_cbct.sh"
CBCTCALLSCRIPT="$DTMFBOX_PATH/script/script_cbct_call.sh"
MISCSCRIPT="$DTMFBOX_PATH/script/script_misc.sh"
TIMERSCRIPT="$DTMFBOX_PATH/script/script_timer.sh"
SEDSCRIPT="$DTMFBOX_PATH/script/script_sed.sh"

# additional binaries for streaming
if [ -f /bin/mkfifo ]; then MKFIFO="/bin/mkfifo"; fi
if [ -f /sbin/mkfifo ]; then MKFIFO="/sbin/mkfifo"; fi
if [ -f /bin/wget ]; then WGET="/bin/wget"; fi
if [ -f /sbin/wget ]; then WGET="/sbin/wget"; fi
if [ -f /bin/ftpput ]; then FTPPUT="/bin/ftpput"; fi
if [ -f /sbin/ftpput ]; then FTPPUT="/sbin/ftpput"; fi
if [ -f /bin/nc ]; then NC="/bin/nc"; fi
if [ -f /sbin/nc ]; then NC="/sbin/nc"; fi
if [ "$MKFIFO" = "" ]; then MKFIFO="$DTMFBOX_PATH/busybox-tools mkfifo"; fi
if [ "$WGET" = "" ]; then WGET="$DTMFBOX_PATH/busybox-tools wget"; fi
if [ "$FTPPUT" = "" ]; then FTPPUT="$DTMFBOX_PATH/busybox-tools ftpput"; fi
if [ "$NC" = "" ]; then NC="$DTMFBOX_PATH/busybox-tools nc"; fi
if [ "$TAR" = "" ] && [ "$DSMOD" = "0" ]; then
  TAR="$DTMFBOX_PATH/busybox-tools tar";
else
  TAR="tar";
fi

# lock script (stop dtmf-event)
script_lock() {
  rm "$DTMFBOX_PATH/tmp/$SRC_CON.dtmf" 2>/dev/null
  echo "1" > "$DTMFBOX_PATH/tmp/$SRC_CON.lock"
}

# unlock script (start dtmf-event)
script_unlock() {  
  rm "$DTMFBOX_PATH/tmp/$SRC_CON.lock" 2>/dev/null
  rm "$DTMFBOX_PATH/tmp/$SRC_CON.getlock" 2>/dev/null
  rm "$DTMFBOX_PATH/tmp/$SRC_CON.dtmf" 2>/dev/null
}

# get a dtmf signal from file (while locked)
get_next_dtmf() {

  if [ ! -f "$DTMFBOX_PATH/tmp/$SRC_CON.lock" ]; then exit 1; fi

  while [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.getlock" ]; do sleep 1; done;
  echo "1" > "$DTMFBOX_PATH/tmp/$SRC_CON.getlock"
  
  if [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.dtmf" ]; then
    DTMF_QUEUE="`cat $DTMFBOX_PATH/tmp/$SRC_CON.dtmf`"
    rm "$DTMFBOX_PATH/tmp/$SRC_CON.dtmf" 2>/dev/null    
  else
    DTMF_QUEUE=""
  fi
 
  let i=0;
  for dtmf in $DTMF_QUEUE
  do
    if [ "$i" = "0" ];
    then      
      DTMF=`echo $dtmf | sed -e "s/\-/\*/g"`
    else
      if [ "$dtmf" != "" ];
      then
        echo "$dtmf" >> "$DTMFBOX_PATH/tmp/$SRC_CON.dtmf"
      fi
    fi

    let i=i+1

  done

  # write rest of dtmfs into file or erase file when no left
  if [ "$i" = "0" ];
  then    
    rm "$DTMFBOX_PATH/tmp/$SRC_CON.getlock"
    return 0
  else
    rm "$DTMFBOX_PATH/tmp/$SRC_CON.getlock"
    return 1
  fi
}

# wait until a dtmf character is received
wait_for_dtmf() {

  DTMF=""
  while [ "$DTMF" = "" ] && [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.lock" ];
  do
   sleep 1
   get_next_dtmf
   if [ "$DTMF" != "" ]; then break; fi
  done

}

# kill dead scripts (outgoing/internal only, $1 = seconds to wait before kill)
kill_dead_scripts() {

  PROCS=`ps -w | grep -e "/bin/sh .*script_.*OUTGOING $SRC_CON" | grep -v "grep" | sed -e "s/ \(.*\) root.*/\1/g"`

  if [ "$1" != "0" ]; then sleep $1; fi

  for proc in $PROCS; do 
    if [ "$proc" != "$$" ]; then kill -9 $proc; fi; 
  done
}

# remove status files
remove_status_files() {
  if [ -f "$PINFILE_DTMF" ]; then rm "$PINFILE_DTMF"; fi
  if [ -f "$CURSCRIPT" ]; then rm "$CURSCRIPT"; fi
  if [ -f "$CURACCOUNT" ]; then rm "$CURACCOUNT"; fi
  if [ -f "$CURCALLBACK" ]; then rm "$CURCALLBACK"; fi
  if [ -f "$TALKING" ]; then rm "$TALKING" 2>/dev/null; fi
}

# --------------------------------------------------
# GLOBAL EVENTS:
# --------------------------------------------------

# save dtmf, when script is locked
if [ "$EVENT" = "DTMF" ] && [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.lock" ];
then  
  while [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.getlock" ]; do sleep 1; done;
  echo "$DTMF" | sed -e "s/\*/\-/g" >> "$DTMFBOX_PATH/tmp/$SRC_CON.dtmf"
  return 1;
fi

# global disconnect event
if [ "$EVENT" = "DISCONNECT" ];
then

   $DTMFBOX $SRC_CON -stop timer
   script_unlock
   remove_status_files

   (kill_dead_scripts "3")&
fi

# --------------------------------------------------------------------------------
# function play_tone
# $1 = 
# "" (stop), "ok", "notok", "beep", "freeline", "busy"
# --------------------------------------------------------------------------------
play_tone() {
  
  if [ "$BATCHMODE" != "1" ];
  then

    case "$1" in
      "")
        $DTMFBOX $SRC_CON -stop tone
      ;;
	  "ok")
        $DTMFBOX $SRC_CON -stop timer
        $DTMFBOX $SRC_CON -timer 250 "TONE_TIMER ok 0 \"$DTMFBOX\" \"$TIMERSCRIPT\"" mode=msec -scriptfile "$TIMERSCRIPT"
      ;;
	  "notok")
        $DTMFBOX $SRC_CON -stop timer
        $DTMFBOX $SRC_CON -timer 250 "TONE_TIMER notok 0 \"$DTMFBOX\" \"$TIMERSCRIPT\"" mode=msec -scriptfile "$TIMERSCRIPT"
      ;;
	  "beep")
        $DTMFBOX $SRC_CON -tone 800 800 1000 1000 32767; sleep 1; $DTMFBOX $SRC_CON -stop tone
      ;;
	  "freeline")
	    $DTMFBOX $SRC_CON -tone 425 425 1000 0 32767
      ;;
	  "busy")
        $DTMFBOX $SRC_CON -tone 425 425 480 480 32767
      ;;
	  "short-busy")
        $DTMFBOX $SRC_CON -tone 425 425 480 480 32767; sleep 2; $DTMFBOX $SRC_CON -stop tone
      ;;
      esac

   fi

}

# --------------------------------------------------------------------------------
# function say_or_beep (espeak/beep.wav) 
# parameter $1="string": words2say
# parameter $2="1": play beep_end.wav
# parameter $3="1": ignore espeak (just play beep/beep.wav)
# 
# when $BATCHMODE is 1, there is no playback.
# --------------------------------------------------------------------------------
say_or_beep() {

  if [ "$BATCHMODE" != "1" ];
  then

    SAY="$1"
    BEEP="$2"
    if [ "$3" = "1" ]; then IGNORE_ESPEAK="1"; else IGNORE_ESPEAK="0"; fi

    ESPEAK_APP=""
    ESPEAK_BUFFSIZE="6400"

    # espeak installed? 
    if [ "$DTMFBOX_ESPEAK" = "2" ];
    then     
      if [ -f $DTMFBOX_PATH/espeak/speak ]; then cd $DTMFBOX_PATH/espeak; ESPEAK_APP="$DTMFBOX_PATH/espeak/speak"; fi
      if [ -f /usr/bin/speak ]; then ESPEAK_APP="/usr/bin/speak"; fi
      SAY=`echo "$SAY" | tr "\n" " "`
      ESPEAK_HZ="16000"
    fi

    # espeak from webstream?
    if [ "$DTMFBOX_ESPEAK" = "1" ]; then 
      SAY=`echo "$SAY" | tr "\n" " " | sed "s/ /%20/g"` 
      ESPEAK_APP="http://www.v3v.de/speak.php";
      ESPEAK_HZ="8000" 
    fi

    # espeak off, just beep?
    if [ "$DTMFBOX_ESPEAK" = "0" ] || [ "$DTMFBOX_ESPEAK" = "" ]; 
    then 
      IGNORE_ESPEAK="1"; 
    fi
   
    # ... say ...
    if [ "$ESPEAK_APP" != "" ] && [ "$IGNORE_ESPEAK" = "0" ];
    then

      # Already speaking? Shut up!
      if [ -f "$TALKING" ];
      then
        $DTMFBOX $SRC_CON -stop play all
        sleep 1        
      fi

      # Not speaking? Then talk!
      if [ ! -f "$TALKING" ];
      then

          $DTMFBOX $SRC_CON -stop play all

          # eSpeak webstream...
          if [ "$DTMFBOX_ESPEAK" = "1" ];
          then
            echo $$ > "$TALKING"
            $MKFIFO "/var/tmp/$SRC_CON-espeak.$$" 2>/dev/null
            $WGET "$ESPEAK_APP?speech=$SAY&speed=$DTMFBOX_ESPEAK_SPEED&pitch=$DTMFBOX_ESPEAK_PITCH&volume=100&lang=de%2B$DTMFBOX_ESPEAK_VOICE$DTMFBOX_ESPEAK_VOICE_TYPE&quality=polyphase&tar=1" -q -O - | $TAR xz -f - -O - > "/var/tmp/$SRC_CON-espeak.$$" &
            $DTMFBOX $SRC_CON -play "/var/tmp/$SRC_CON-espeak.$$" mode=stream hz=$ESPEAK_HZ bufsize=$ESPEAK_BUFFSIZE wait_start=200 wait_end=20 #>/dev/null
            rm "/var/tmp/$SRC_CON-espeak.$$" 2>/dev/null
            rm "$TALKING" 2>/dev/null
          fi

          # eSpeak installed...
          if [ "$DTMFBOX_ESPEAK" = "2" ];
          then
            echo $$ > "$TALKING"
            $MKFIFO "/var/tmp/$SRC_CON-espeak.$$" 2>/dev/null
            $ESPEAK_APP -v de+$DTMFBOX_ESPEAK_VOICE$DTMFBOX_ESPEAK_VOICE_TYPE -s $DTMFBOX_ESPEAK_SPEED -p $DTMFBOX_ESPEAK_PITCH --stdout "$SAY" > "/var/tmp/$SRC_CON-espeak.$$" &
            $DTMFBOX $SRC_CON -play "/var/tmp/$SRC_CON-espeak.$$" mode=stream hz=$ESPEAK_HZ bufsize=$ESPEAK_BUFFSIZE wait_start=25 wait_end=10 >/dev/null
            rm "/var/tmp/$SRC_CON-espeak.$$" #2>/dev/null
            rm "$TALKING" 2>/dev/null
          fi

        cd $DTMFBOX_PATH
      fi

    # no? just beep...
    else

      if [ "$BEEP" = "1" ]; 
      then
        # not-ok
        play_tone "notok"
      else
        # ok
		play_tone "ok"
      fi
    fi

  fi
}

# --------------------------------------------------------------------------------
# change scriptfile and say something
# "$1" = scriptfile
# "$2" = say (when given)
# --------------------------------------------------------------------------------
redirect() {

   # change scriptfile   
   $DTMFBOX $SRC_CON -scriptfile "$1"

   # save scriptfile
   echo "$1" > "$CURSCRIPT"

   # say?
   if [ "$2" != "" ];
   then
     say_or_beep "$2" "0"
   fi
}


# --------------------------------------------------------------------------------
# save settings (dsmod or usb)
# "$1" = key
# "$2" = value
# --------------------------------------------------------------------------------
save_settings() {

   DTMFBOX_SETTINGS_KEY="$1"
   DTMFBOX_SETTINGS_VAL="$2"

   # save usb/standalone
   if [ "$DSMOD" = "0" ];
   then
     rm $DTMFBOX_PATH/tmp/cfg1.tmp 2>/dev/null
     rm $DTMFBOX_PATH/tmp/cfg2.tmp 2>/dev/null
     cat "$DTMFBOX_CFG"  | sed "s/export $DTMFBOX_SETTINGS_KEY='\(.*\)'/export $DTMFBOX_SETTINGS_KEY='$DTMFBOX_SETTINGS_VAL'/g" > $DTMFBOX_PATH/tmp/cfg1.tmp
     cat "$DTMFBOX_BOOT" | sed "s/export $DTMFBOX_SETTINGS_KEY='\(.*\)'/export $DTMFBOX_SETTINGS_KEY='$DTMFBOX_SETTINGS_VAL'/g" > $DTMFBOX_PATH/tmp/cfg2.tmp
     if [ -f $DTMFBOX_PATH/tmp/cfg1.tmp ] && [ -f $DTMFBOX_PATH/tmp/cfg2.tmp ]; then 
       cat $DTMFBOX_PATH/tmp/cfg1.tmp > $DTMFBOX_CFG
       cat $DTMFBOX_PATH/tmp/cfg2.tmp > $DTMFBOX_BOOT
       chmod +x $DTMFBOX_CFG
       chmod +x $DTMFBOX_BOOT
     fi

   # save dsmod
   else

     modconf set dtmfbox "$DTMFBOX_SETTINGS_KEY=$DTMFBOX_SETTINGS_VAL"
     modconf save dtmfbox
     modsave

   fi
}

# --------------------------------------------------------------------------------
# search for MSN, set variables
# --------------------------------------------------------------------------------
search4msn() {

 # account no from file or parameter?
 if [ -f "$CURACCOUNT" ]; then export ACC_NO=`cat "$CURACCOUNT"`; fi
 let cnt="$ACC_NO"

 SEMI=";"

 LIST=""
 LIST="$LIST ACC_MSN=\"\$DTMFBOX_ACC${cnt}_NUMBER\"$SEMI" 
 LIST="$LIST AM=\"\$DTMFBOX_SCRIPT_ACC${cnt}_AM\"$SEMI"
 eval $LIST
 
 # Answering machine settings
 LIST=""
 if [ "$AM" = "1" ];
 then    
   LIST="$LIST AM_PIN=\"\$DTMFBOX_SCRIPT_ACC${cnt}_AM_PIN\"$SEMI"        
   LIST="$LIST RECORD=\"\$DTMFBOX_SCRIPT_ACC${cnt}_RECORD\"$SEMI"        
   LIST="$LIST TIMEOUT=\"\$DTMFBOX_SCRIPT_ACC${cnt}_TIMEOUT\"$SEMI"        
   LIST="$LIST RINGTIME=\"\$DTMFBOX_SCRIPT_ACC${cnt}_RINGTIME\"$SEMI"        
   LIST="$LIST UNKNOWN_ONLY=\"\$DTMFBOX_SCRIPT_ACC${cnt}_UNKNOWN_ONLY\"$SEMI"        
   LIST="$LIST BEEP=\"\$DTMFBOX_SCRIPT_ACC${cnt}_BEEP\"$SEMI"        
   LIST="$LIST ANNOUNCEMENT=\"\$DTMFBOX_SCRIPT_ACC${cnt}_ANNOUNCEMENT\"$SEMI"        
   LIST="$LIST ANNOUNCEMENT_END=\"\$DTMFBOX_SCRIPT_ACC${cnt}_ANNOUNCEMENT_END\"$SEMI"        
   LIST="$LIST ON_AT=\"\$DTMFBOX_SCRIPT_ACC${cnt}_ON_AT\"$SEMI"        
   LIST="$LIST OFF_AT=\"\$DTMFBOX_SCRIPT_ACC${cnt}_OFF_AT\"$SEMI"        

   # mailer settings
   LIST="$LIST MAIL_ACTIVE=\"\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_ACTIVE\"$SEMI"        
   LIST="$LIST MAIL_FROM=\"\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_FROM\"$SEMI"        
   LIST="$LIST MAIL_TO=\"\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_TO\"$SEMI"        
   LIST="$LIST MAIL_SERVER=\"\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_SERVER\"$SEMI"
   LIST="$LIST MAIL_USER=\"\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_USER\"$SEMI"
   LIST="$LIST MAIL_PASS=\"\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_PASS\"$SEMI"
   LIST="$LIST MAIL_DELETE=\"\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_DELETE\"$SEMI"

   # ftp streamer settings
   LIST="$LIST FTP_ACTIVE=\"\$DTMFBOX_SCRIPT_ACC${cnt}_FTP_ACTIVE\"$SEMI"
   LIST="$LIST FTP_USER=\"\$DTMFBOX_SCRIPT_ACC${cnt}_FTP_USER\"$SEMI"
   LIST="$LIST FTP_PASS=\"\$DTMFBOX_SCRIPT_ACC${cnt}_FTP_PASS\"$SEMI"
   LIST="$LIST FTP_SERVER=\"\$DTMFBOX_SCRIPT_ACC${cnt}_FTP_SERVER\"$SEMI"
   LIST="$LIST FTP_PORT=\"\$DTMFBOX_SCRIPT_ACC${cnt}_FTP_PORT\"$SEMI"
   LIST="$LIST FTP_PATH=\"\$DTMFBOX_SCRIPT_ACC${cnt}_FTP_PATH\"$SEMI"
 fi
 eval $LIST
 if [ "$ON_AT" = "" ]; then ON_AT="00:00"; fi
 if [ "$OFF_AT" = "" ]; then OFF_AT="00:00"; fi

 # cb/ct settings
 LIST=""
 CBCT_ACTIVE=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_CBCT_ACTIVE` 
 if [ "$CBCT_ACTIVE" = "1" ];
 then
   LIST="$LIST CBCT_TRIGGERNO=\"\$DTMFBOX_SCRIPT_ACC${cnt}_CBCT_TRIGGERNO\"$SEMI"        
   LIST="$LIST CBCT_PINCODE=\"\$DTMFBOX_SCRIPT_ACC${cnt}_CBCT_PINCODE\"$SEMI"        
   LIST="$LIST CBCT_TYPE=\"\$DTMFBOX_SCRIPT_ACC${cnt}_CBCT_TYPE\"$SEMI"        
   eval $LIST
  else            
	CBCT_TRIGGERNO=""
	CBCT_TYPE=""
  fi

  # should not happen...
  if [ "$ACC_MSN" = "" ]; then 
     echo "script_funcs.sh : $SRC_NO not found in settings!"
     return 1; 
  fi
}

# --------------------------------------------------------------------------------
# Dummy functions. Can be overridden by userdefined script. Before & After Events.
# When you return 1 in a *_before function, the real function won't be called!
# --------------------------------------------------------------------------------

#
# script_main.sh
#

internal_dial_before() {
  return 0;
}

internal_dial_after() {
  return 0;
}

callback_callthrough_before() {
  return 0;
}

callback_callthrough_after() {
  return 0;
}

answering_machine_before() {
  return 0;
}

answering_machine_after() {
  return 0;
}

administration_before() {
  return 0;
}

administration_after() {
  return 0;
}

mailer_before() {
  return 0;
}

mailer_after() {
  return 0;
}


#
# script_am_admin.sh
#

play_message_before() {
  return 0;
}

play_message_after() {
  return 0;
}


#
# script_dtmf.sh
#

dtmf_commands_pincheck_before() {
  return 0;
}

dtmf_commands_pincheck_after() {
  return 0;
}

dtmf_commands_before() {
  return 0;
}

dtmf_commands_after() {
  return 0;
}


#
# script_cbct.sh
#

cbct_askpin_before() {
  return 0;
}

cbct_askpin_after() {
  return 0;
}

cbct_choose_account_before() {
  return 0;
}

cbct_choose_account_after() {
  return 0;
}

cbct_call_internal_before() {
  return 0;
}

cbct_call_internal_after() {
  return 0;
}

cbct_call_external_before() {
  return 0;
}

cbct_call_external_after() {
  return 0;
}

cbct_do_call_before() {
  return 0;
}

cbct_do_call_after() {
  return 0;
}

# --------------------------------------------------------------------------------
# execute user-script (global), if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="GLOBAL"
  . $USERSCRIPT
  if [ "$?" = "1" ]; then exit 1; fi
fi
