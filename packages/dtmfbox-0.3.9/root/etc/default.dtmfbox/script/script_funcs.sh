#!/bin/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox v0.3.9 - script funcs (c) 2007 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# Load configuration
# --------------------------------------------------------------------------------
# dsmod ..
if [ -f /mod/etc/conf/dtmfbox.cfg ]; then
  . /mod/etc/conf/dtmfbox.cfg
  if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
  DTMFBOX="dtmfbox"
  USERSCRIPT="/var/tmp/flash/dtmfbox_userscript.sh"
fi

# .. standalone
if [ -f /var/dtmfbox/dtmfbox.save ]; then
  . /var/dtmfbox/dtmfbox.save
  if [ "$DTMFBOX_PATH" = "" ]; then DTMFBOX_PATH="/var/dtmfbox"; fi
  DTMFBOX="$DTMFBOX_PATH/dtmfbox"
  USERSCRIPT="$DTMFBOX_PATH/script/dtmfbox_userscript.sh"
fi

# no configuration? abort!
if [ ! -f /mod/etc/conf/dtmfbox.cfg ] && [ ! -f /var/dtmfbox/dtmfbox.save ]; then
  echo "script_funcs.sh : configuration not found!"
  echo "                  dsmod: /mod/etc/conf/dtmfbox.cfg"
  echo "                  usb:   /var/dtmfbox/dtmfbox.save"
  exit 1;
fi

# --------------------------------------------------------------------------------
# Parameter
# --------------------------------------------------------------------------------
EVENT="$1"                    # CONNECT, CONFIRMED, DTMF, DISCONNECT
TYPE="$2"                     # VOIP, ISDN
IN_OUT="$3"                   # INCOMING, OUTGOING
SRC_CON="$4"                  # Source-Connection ID
SRC_NO="$6"                   # Source-No.
DST_CON="$5"                  # Target-Connection ID
DST_NO="$7"                   # Target-No.
DTMF="$8"                     # DTMF

# soundfiles
WAV_BEEP="$DTMFBOX_PATH/play/beep.wav"
WAV_BEEP_END="$DTMFBOX_PATH/play/beep_end.wav"

# files needed by script_cbct.sh and script_main.sh
MSNFILE="$DTMFBOX_PATH/tmp/cbct_msn_$SRC_CON.tmp"
PINFILE="$DTMFBOX_PATH/tmp/cbct_pin_$SRC_CON.tmp"
ACCFILE="$DTMFBOX_PATH/tmp/cbct_acc_$SRC_CON.tmp"
CONFILE="$DTMFBOX_PATH/tmp/cbct_con_$SRC_CON.tmp"

# files needed by script_admin.sh
PINFILE_ADMIN="$DTMFBOX_PATH/tmp/admin_pin_$SRC_CON.tmp"

# scripts
ADMINSCRIPT="$DTMFBOX_PATH/script/script_admin.sh"
CBCTSCRIPT="$DTMFBOX_PATH/script/script_cbct.sh"
CBCTCALLSCRIPT="$DTMFBOX_PATH/script/script_cbct_call.sh"


# --------------------------------------------------------------------------------
# function say_or_beep (espeak/beep.wav) 
# parameter $1="string": words2say
# parameter $2="1": play beep_end.wav
# parameter $3="1": ignore espeak (just play beep/beep_end)
# --------------------------------------------------------------------------------
say_or_beep() {

  SAY="$1"
  if [ "$3" = "1" ]; then IGNORE_ESPEAK="1"; else IGNORE_ESPEAK="0"; fi

  # beep.wav (ok) or beep_end.wav (not ok)
  if [ "$2" = "1" ]; then
    BEEP=$WAV_BEEP_END
  else
    BEEP=$WAV_BEEP
  fi

  # got espeak? say...
  if [ -f $DTMFBOX_PATH/espeak/speak ] && [ "$IGNORE_ESPEAK" = "0" ];
  then
    
    if [ ! -f $DTMFBOX_PATH/tmp/$SRC_CON.wav ];
    then

      cd $DTMFBOX_PATH/espeak
      $DTMFBOX_PATH/espeak/speak -v de -w $DTMFBOX_PATH/tmp/$SRC_CON.wav "$SAY" 2>/dev/null

      if [ -f $DTMFBOX_PATH/tmp/$SRC_CON.wav ]; 
      then
        $DTMFBOX $SRC_CON -play $DTMFBOX_PATH/tmp/$SRC_CON.wav
        rm $DTMFBOX_PATH/tmp/$SRC_CON.wav
      else
        $DTMFBOX $SRC_CON -playthread $BEEP
      fi

      cd $DTMFBOX_PATH
    fi

  # no? just beep...
  else

    $DTMFBOX $SRC_CON -playthread $BEEP

  fi

}

# --------------------------------------------------------------------------------
# function no2word - parameter $1: no |  return $NO_WORD = string (no_in_words)
# --------------------------------------------------------------------------------
no2word() {

 NO_1="erste"
 NO_2="zweite"
 NO_3="dritte"
 NO_4="vierte"
 NO_5="fuenfte"
 NO_6="sechste"
 NO_7="siebte"
 NO_8="achte"
 NO_9="neunte"
 NO_10="zehnte"
 NO_11="elfte"
 NO_12="zwoelfte"
 NO_13="dreizehnte"
 NO_14="vierzehnte"
 NO_15="fuenfzehnte"
 NO_16="sechzehnte"
 NO_17="siebzehnte"
 NO_18="achzehnte"
 NO_19="neunzehnte"
 NO_20="zwanzigste"
 NO_21="einundzwanzigste"
 NO_22="zweiundzwanzigste"
 NO_23="dreiundzwanzigste"
 NO_24="vierundzwanzigste"
 NO_25="fuenfundzwanzigste"
 NO_26="sechsundzwanzigste"
 NO_27="siebenundzwanzigste"
 NO_28="achtundzwanzigste"
 NO_29="neunundzwanzigste"
 NO_30="dreissigste"
 NO_31="einunddreissigste"

 NO_REAL="$1"
 NO_WORD=""
 NO_WORD=`eval echo \\$NO_${NO_REAL}`
 if [ "NO_WORD" = "" ]; then NO_WORD="$NO_REAL'ste"; fi

}

# --------------------------------------------------------------------------------
# create email body and subject
# --------------------------------------------------------------------------------
create_mail() {

MAIL_SUBJECT="dtmfbox - Anrufbeantworter - von $DST_NO an $SRC_NO"

cat << EOF > $DTMFBOX_PATH/tmp/inline_$SRC_CON.txt
----------------------------------------------------------------
 dtmfbox - Anrufbeantworter
----------------------------------------------------------------
 Anruf ($TYPE)
 von $DST_NO für $SRC_NO
 $DATETEXT
----------------------------------------------------------------
EOF
}

# --------------------------------------------------------------------------------
# mailer-function
# --------------------------------------------------------------------------------
mailer() {

  if [ "$MAIL_ACTIVE" = "1" ]; 
  then

    if [ -f "$RECFILE" ] && [ "$MAIL_TO" != "" ]; 
    then   

      # create mail body & subject
      #       
      create_mail

      # send mail
      #
      /sbin/mailer -s "$MAIL_SUBJECT" \
             -f "$MAIL_FROM" \
             -t "$MAIL_TO" \
             -m "$MAIL_SERVER" \
             -a "$MAIL_USER" \
             -w "$MAIL_PASS" \
             -d "$RECFILE" \
             -i "$DTMFBOX_PATH/tmp/inline_$SRC_CON.txt"

      # remove mail-body
      #
      rm "$DTMFBOX_PATH/tmp/inline_$SRC_CON.txt"

      # delete recording?
      #
      if [ "$MAIL_DELETE" = "1" ];
      then
        rm "$RECFILE"
      fi

    fi
  fi

}

# --------------------------------------------------------------------------------
# check, if the configured timespan is valid
# --------------------------------------------------------------------------------
check_time() {

   let H_START="`echo $ON_AT | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
   let M_START="`echo $ON_AT | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"
   let H_END="`echo $OFF_AT | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
   let M_END="`echo $OFF_AT | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"

   if [ "$M_END" = "0" ]; then
    let M_END=60
   fi
   if [ "$H_END" = "0" ]; then
    let H_END=24
   fi

   let H="`date +'%H' | sed -e 's/^0\(.*\)/\1/g'`"
   let M="`date +'%M' | sed -e 's/^0\(.*\)/\1/g'`"

   ok=0

   if [ $H_START -le $H ] && [ $H -le $H_END ];
   then
     if [ "$H_START" = "$H" ] || [ "$H_END" = "$H" ]; 
     then
       if [ $M_START -le $M ] && [ $M -le $M_END ]; 
       then
         ok=1
       fi
     else
       ok=1
     fi
   fi

   return $ok
}

# --------------------------------------------------------------------------------
# kill idle script
# --------------------------------------------------------------------------------
kill_idle() {

    # 
    # Read PID file from idle-script and kill it!
    # 
    if [ -f "$DTMFBOX_PATH/tmp/script_idle_$SRC_CON.pid" ];
    then
      PID="`cat \"$DTMFBOX_PATH/tmp/script_idle_$SRC_CON.pid\"`"
      if [ "$PID" != "" ]; 
      then
        kill $PID
      fi

      # remove pid file
      rm $DTMFBOX_PATH/tmp/script_idle_$SRC_CON.pid 2>/dev/null
      
    else
      return 0
    fi

    return 1
}

# --------------------------------------------------------------------------------
# search for MSN, set variables
# --------------------------------------------------------------------------------
search4msn() {

	ACC_MSN=""
	let cnt=1

    # walkthrough each account
	while [ $cnt -le 10 ];
	do

	   ACC_MSN=`eval echo \\$DTMFBOX_ACC${cnt}_MSN`
	
	   if [ "$ACC_MSN" = "$SRC_NO" ]; then
	
	     # Account found!
	     AM=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_AM`
	     RECORD=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_RECORD`       
	     TIMEOUT=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_TIMEOUT`
	     RINGTIME=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_RINGTIME`
         BEEP=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_BEEP`
	     ANNOUNCEMENT=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_ANNOUNCEMENT`
	     ANNOUNCEMENT_END=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_ANNOUNCEMENT_END`
         ON_AT=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_ON_AT`
         OFF_AT=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_OFF_AT`
	     if [ "$ON_AT" = "" ]; then ON_AT="00:00"; fi
	     if [ "$OFF_AT" = "" ]; then OFF_AT="00:00"; fi

         # mailer settings
	     MAIL_ACTIVE=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_ACTIVE`
         if [ "$MAIL_ACTIVE" = "1" ]; 
         then
 	       MAIL_FROM=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_FROM`
	       MAIL_TO=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_TO`
	       MAIL_SERVER=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_SERVER`
	       MAIL_USER=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_USER`
	       MAIL_PASS=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_PASS`
	       MAIL_DELETE=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_MAIL_DELETE`
         else
           MAIL_ACTIVE="0"
         fi
	
	     # cb/ct settings
	     CBCT_TRIGGERNO=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_CBCT_TRIGGERNO`
         CBCT_PINCODE=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_CBCT_PINCODE`

	     if [ "$CBCT_TRIGGERNO" != "" ]; then
	       CBCT="1"
           CBCT_TYPE=`eval echo \\$DTMFBOX_SCRIPT_ACC${cnt}_CBCT_TYPE`
	     else
	       CBCT="0"
	       CBCT_TYPE=""
	     fi
	
	     break
	   fi
	
	   ACC_MSN=""
	   let cnt=$cnt+1
	
	done
	
	# should not happen...
	if [ "$ACC_MSN" = "" ]; then 
      echo "script_funcs.sh : $SRC_NO not found in settings!"
      exit 1; 
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
# script_admin.sh
#

play_message_before() {
  return 0;
}

play_message_after() {
  return 0;
}

admin_callthrough_before() {
  return 0;
}

admin_callthrough_after() {
  return 0;
}

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
