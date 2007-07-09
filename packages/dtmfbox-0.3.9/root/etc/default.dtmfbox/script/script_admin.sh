#!/bin/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox v0.3.9 - administration script (c) 2007 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------

. ./script/script_funcs.sh

# ------------------------------------------------------------------------
# Play a wave file at position (1# - xxx#)
# ------------------------------------------------------------------------
play_message() {

  let i=1;
  found=0;
    
  for file in `find $DTMFBOX_PATH/record/$SRC_NO/* | grep .*wav`
  do
    # search file (by no.)
    if [ "$i" = "$DTMF" ];
    then
      found=1
      break 1
    fi	  
 
    let i=i+1
  done

  # Play file, say date!
  if [ "$found" = "1" ]; then	  
    # convert no to words ;)
    DD=`date -r $file +'%d' | sed 's/0\(.\)/\1/g'`
    MM=`date -r $file +'%m' | sed 's/0\(.\)/\1/g'`
    H=`date -r $file +'%H' | sed 's/0\(.\)/\1/g'`
    M=`date -r $file +'%M' | sed 's/0\(.\)/\1/g'`
    no2word $DD; DD="$NO_WORD"
    no2word $MM; MM="$NO_WORD"
    no2word $DTMF; MSG_NO="$NO_WORD"

    # say ...
    say_or_beep "$MSG_NO, Nachricht, am $DD'n $MM'n - um $H Uhr $M."

    # .. and play!
    $DTMFBOX $SRC_CON -playthread $file

    exit 1;
  fi

}

# ------------------------------------------------------------------------
# Extra pincode check for DTMF-commands (outgoing & internal only!) (Pincode#)
# ------------------------------------------------------------------------
dtmf_commands_pincheck() {

 if [ "$DTMF" = "$DTMFBOX_SCRIPT_PINCODE" ] && [ "$IN_OUT" = "OUTGOING" ]; 
 then

    # status only when internal (outgoing)
    if [ "$IN_OUT" = "OUTGOING" ]; then
      say_or_beep "Pin akzeptiert."
    fi

    # save pincode to file
    echo "$DTMFBOX_SCRIPT_PINCODE" > "$PINFILE_ADMIN"
    exit 1;
 fi

}

# ------------------------------------------------------------------------
# Userdefined DTMF-commands (*1# - *50#)
# ------------------------------------------------------------------------
dtmf_commands() {

  let i=1

  while [ $i -le 50 ];
  do
     
    USERDTMF=`eval echo ${i}`
    if [ "$DTMF" = "*$USERDTMF" ]; 
    then        

      # readin pincode
      if [ -f $PINFILE_ADMIN ]; then GOTPIN=`cat "$PINFILE_ADMIN"`; else GOTPIN=""; fi

      # check pin (internal only!)
      if [ "$GOTPIN" = "$DTMFBOX_SCRIPT_PINCODE" ] || [ "$IN_OUT" = "INCOMING" ];
      then

        # say (status)
        say_or_beep "Befehl $USERDTMF"

        # execute command
        USERCMD=`eval echo \\$DTMFBOX_SCRIPT_CMD_${i}`
        eval $USERCMD        

      # no pin (internal only)!
      else
        say_or_beep "Bitte Pin eingeben." "1"
      fi

      exit 1;
    fi

    let i=$i+1

  done 
}

# ------------------------------------------------------------------------
# Callthrough (**#)
# ------------------------------------------------------------------------
admin_callthrough() {

  if [ "$DTMF" = "**" ];
  then

    # remove pincode file
    if [ -f $PINFILE_ADMIN ]; then rm "$PINFILE_ADMIN"; fi

    search4msn

    # no pincode for callthrough? create pinfile...
    if [ "$CBCT_PINCODE" = "" ];
    then
      echo "NOPIN" > "$PINFILE"
      say_or_beep "Account 1 bis 10 waehlen oder 0 fuer interne Verbindung." 
    else
      say_or_beep "Bitte Pin eingeben fuer die Durchwahl."
    fi

    # change scriptfile
    $DTMFBOX $SRC_CON -scriptfile "$CBCTSCRIPT"
    exit 1;

  fi

}

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="ADMIN"

  . $USERSCRIPT

  # returned 1? exit!
  if [ "$?" = "1" ]; then exit 1; fi
fi



# --------------------------------------------------------------------------------
# change SRC_NO (internal only !! - search account (*#100# - *#109#))
# --------------------------------------------------------------------------------
if [ "$IN_OUT" = "OUTGOING" ];
then

  # get account id (from dialstring, e.g *#101# = Account 1)
  ACC_ID=`echo $DST_NO | sed 's/.*10//g' | sed 's/#.*//g' | sed 's/@.*//g'`
  let ACC_ID=${ACC_ID}+1

  # get account by id 
  NEW_ACC_MSN=`eval echo \\$DTMFBOX_ACC${ACC_ID}_MSN`

  if [ "$NEW_ACC_MSN" != "" ]; then 

    # change source-no (to play files from)
    ACC_MSN=$NEW_ACC_MSN
    SRC_NO=$NEW_ACC_MSN

  fi


fi

# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_main.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ]; 
then 

  # count messages...
  let msg=0
  for file in `find $DTMFBOX_PATH/record/$SRC_NO/* | grep .*wav`
  do
	let msg=msg+1
  done

  # create text
  if [ "$msg" = "0" ]; then 
	 msg="Sie haben keine neuen Nachrichten."; 
  else
	if [ "$msg" = "1" ]; then 
	   msg="Sie haben eine neue Nachricht."; 
	else
	   msg="Sie haben $msg neue Nachrichten.";
	fi
  fi

  # say no. of messages (or beep)
  say_or_beep "$msg"

fi


# --------------------------------------------------------------------------------
# DTMF-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DTMF" ]; 
then 
 
    # Play recorded messages (1# - xxx#)
    #
    play_message_before
    if [ "$?" = "0" ]; then play_message; fi
    play_message_after

    # Callthrough (**#)
    #
    admin_callthrough_before
    if [ "$?" = "0" ]; then admin_callthrough; fi
    admin_callthrough_after    

    # Extra pincheck for DTMF-commands (outgoing/internal only!
    #
    dtmf_commands_pincheck_before
    if [ "$?" = "0" ]; then dtmf_commands_pincheck; fi
    dtmf_commands_pincheck_after


    # Userdefined DTMF-commands (*1# - *50#)
    #
    dtmf_commands_before
    if [ "$?" = "0" ]; then dtmf_commands; fi
    dtmf_commands_after

    exit 1;
fi

# --------------------------------------------------------------------------------
# DISCONNECT-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DISCONNECT" ]; 
then 

  # remove pincode file
  if [ -f $PINFILE_ADMIN ]; then rm "$PINFILE_ADMIN"; fi

fi


