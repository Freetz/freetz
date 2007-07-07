#!/bin/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox v0.3.9 - callback-/callthrough-script (c) 2007 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------

. ./script/script_funcs.sh

# check if a MSN file exists..
if [ -f $MSNFILE ]; then GOTMSN=`cat "$MSNFILE"`; else GOTMSN=""; fi

# check if already logged in..
if [ -f $PINFILE ]; then GOTPIN=`cat "$PINFILE"`; else GOTPIN=""; fi

# check if already choosed an account
if [ -f $ACCFILE ]; then GOTACC=`cat "$ACCFILE"`; else GOTACC=""; fi

# check if already made a call
if [ -f $CONFILE ]; then GOTCON=`cat "$CONFILE"`; else GOTCON=""; fi


# --------------------------------------------------------------------------------
# On disconnect or menu change
# --------------------------------------------------------------------------------
cbct_exit() {

  # hook down (when there is an active call!)
  if [ "$GOTCON" != "" ]; then
    $DTMFBOX $GOTCON -hook down
  fi

  # remove (exchange)-files
  if [ -f $MSNFILE ]; then rm "$MSNFILE"; fi
  if [ -f $PINFILE ]; then rm "$PINFILE"; fi
  if [ -f $ACCFILE ]; then rm "$ACCFILE"; fi
  if [ -f $CONFILE ]; then rm "$CONFILE"; fi

}

# --------------------------------------------------------------------------------
# Ask for pincode
# --------------------------------------------------------------------------------
cbct_askpin() {

 # get acc_msn from file - use setting from called account!
 if [ "$GOTMSN" != "" ]; then SRC_NO="$GOTMSN"; fi

 # return to script_admin.sh?
 if [ "$DTMF" = "*" ];
 then
   cbct_exit
   $DTMFBOX $SRC_CON -scriptfile "$ADMINSCRIPT"
   say_or_beep "" "0" "1"
   exit 1
 fi

 # load cb/ct settings
 search4msn

 # check pincode
 if [ "$CBCT_PINCODE" = "$DTMF" ]; then
   echo "$DTMF" > "$PINFILE"
   say_or_beep "Pin akzeptiert. Account 1 bis 10 waehlen oder 0 fuer interne Verbindung."        
   exit 1
 else      
   say_or_beep "Pin fehlerhaft." "1"
   exit 1
 fi

}

# --------------------------------------------------------------------------------
# Choose an account to call out (internal: 0#, external: 1# - 10#)
# --------------------------------------------------------------------------------
cbct_choose_account() {

  # return to script_admin.sh?
  if [ "$DTMF" = "*" ];
  then
    cbct_exit
    $DTMFBOX $SRC_CON -scriptfile "$ADMINSCRIPT"
    say_or_beep "" "0" "1"
    exit 1
  fi

  # call internal?
  if [ "$DTMF" = "0" ];
  then

    echo "-1" > "$ACCFILE"
    say_or_beep "Interne Verbindung."
    exit 1;
        
  # call external / account?
  else
      
    let DTMF_ID=$DTMF  
    ACC_MSN=`eval echo \\$DTMFBOX_ACC${DTMF_ID}_MSN`

    if [ "$ACC_MSN" = "" ]; 
    then
       say_or_beep "Eingabe fehlerhaft. Account 1 bis 10 waehlen oder 0 fuer interne Verbindung." "1"
    else
       echo "$DTMF" > "$ACCFILE"
       say_or_beep "Account Nummer $DTMF_ID. Bitte Nummer waehlen."
    fi

    exit 1
  fi

}

# --------------------------------------------------------------------------------
# Make a call (internal/external)
# --------------------------------------------------------------------------------
cbct_do_call() {

  if [ "$ACC_MSN" != "" ];
  then

    # get old conid from file (disconnect old call - redial)
    if [ "$GOTCON" != "" ];
    then
      $DTMFBOX $GOTCON -hook down
      rm "$CONFILE"
      sleep 1
    fi

    # make new call
    if [ "$DTMF" != "" ];
    then
      say_or_beep "Verbindung wird hergestellt."

      # make call        
      CALL_ID=`$DTMFBOX $SRC_CON -call $ACC_MSN $DTMF $CTRL_INTERNAL`

      # change scriptfile for call (script_cbct_call.sh - to receive disconnect)
      $DTMFBOX $CALL_ID -scriptfile "$CBCTCALLSCRIPT"
      sleep 1
    fi

    # save new conid to file
    if [ "$CALL_ID" != "" ]; then echo "$CALL_ID" > "$CONFILE"; fi

  else
      echo "script_cbct.sh : MSN not found in settings!"
      exit 1;
  fi

}

# --------------------------------------------------------------------------------
# Make an internal call (0#)
# --------------------------------------------------------------------------------
cbct_call_internal() {

  # set destination-no as call msn
  ACC_MSN="$DST_NO"
  CTRL_INTERNAL="$DTMFBOX_CAPI_INTERNAL"

  # call
  cbct_do_call_before  
  if [ "$?" = "0" ]; then cbct_do_call; fi
  cbct_do_call_after
}

# --------------------------------------------------------------------------------
# Make an external call (1# - 10#)
# --------------------------------------------------------------------------------
cbct_call_external() {

  # set choosen account as ACC_MSN
  let DTMF_ID=$GOTACC
  let DTMF_ID=DTMF_ID
  ACC_MSN=`eval echo \\$DTMFBOX_ACC${DTMF_ID}_MSN`
  CTRL_INTERNAL=""

  # call
  cbct_do_call_before
  if [ "$?" = "0" ]; then cbct_do_call; fi
  cbct_do_call_after
}


# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="CBCT"

  . $USERSCRIPT

  # returned 1? exit!
  if [ "$?" = "1" ]; then exit 1; fi
fi


# --------------------------------------------------------------------------------
# CONFIRMED-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "CONFIRMED" ];
then

  # remove (exchange)-files
  if [ -f $PINFILE ]; then rm "$PINFILE"; fi
  if [ -f $ACCFILE ]; then rm "$ACCFILE"; fi
  if [ -f $CONFILE ]; then rm "$CONFILE"; fi

fi

# --------------------------------------------------------------------------------
# DTMF-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DTMF" ]; 
then

  # 1. no pin?
  if [ "$GOTPIN" = "" ];
  then

    cbct_askpin_before
    if [ "$?" = "0" ]; then cbct_askpin; fi
    cbct_askpin_after

  # 2. pin was ok!
  # now ask for the account to dial out (1# - 10# or 0# for internal call)
  else
    
     if [ "$GOTACC" = "" ];
     then

       cbct_choose_account_before
       if [ "$?" = "0" ]; then cbct_choose_account; fi
       cbct_choose_account_after

     # 3. account was ok!
     # now ask for the number to call...
     else

        # return to last menue (choose account)?
        if [ "$DTMF" = "*" ];
        then
          GOTACC="";
          if [ -f $ACCFILE ]; then rm "$ACCFILE"; fi
          say_or_beep "Account 1 bis 10 waehlen oder 0 fuer interne Verbindung." 
          exit 1;
        fi

        # reset number (do not dial, if any * is in the number)
        RESET_NO=`echo "$DTMF" | sed 's/.*\(\*\).*/\1/g'`
        if [ "$RESET_NO" = "*" ];
        then
          DTMF=""
          say_or_beep "Wehlvorgang abgebrochen."
          exit 1;
        fi

        # internal call (0#) / external call (account 1# - 10#)
        if [ "$GOTACC" = "-1" ]; 
        then
          cbct_call_internal_before
          if [ "$?" = "0" ]; then cbct_call_internal; fi
          cbct_call_internal_after
        else
          cbct_call_external_before
          if [ "$?" = "0" ]; then cbct_call_external; fi
          cbct_call_external_after
        fi              
          
     fi
            
  fi
fi


# --------------------------------------------------------------------------------
# DISCONNECT-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DISCONNECT" ];
then
  cbct_exit
fi

