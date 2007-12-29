#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - callback-/callthrough-scriptnwering machine administration
# --------------------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# --------------------------------------------------------------------------------
# On disconnect or menu change
# --------------------------------------------------------------------------------
cbct_exit() {

  # hook down (when there is an active call!)
  if [ "$GOTCON" != "" ]; then
    $DTMFBOX $GOTCON -hook down
  fi

}

# --------------------------------------------------------------------------------
# Ask for pincode
# --------------------------------------------------------------------------------
cbct_ask_pin() {

  DTMF=""
  if [ "$CBCT_PINCODE" != "" ];
  then
    while [ "$DTMF" != "$CBCT_PINCODE" ];
    do
      wait_for_dtmf

      if [ "$DTMF" = "" ]; then return 1; fi

      if [ "$DTMF" = "*" ]; then 
        if [ ! -f "$CURCALLBACK" ];
        then
          return 1; 
        fi
      fi

      if [ "$DTMF" = "$CBCT_PINCODE" ]; then 
        break; 
      fi

      (say_or_beep "Pin fehlerhaft!")&
      DTMF=""
    done

    (say_or_beep "Pin akzeptiert. Bitte Account waehlen.")&
  fi

  if [ -f "$CURCALLBACK" ]; then rm "$CURCALLBACK"; fi
}

cbct_ask_account() {

  DTMF=""
  while [ "$DTMF" = "" ];
  do
    wait_for_dtmf
    if [ "$DTMF" = "" ]; then return 1; fi

    if [ "$DTMF" = "*" ]; then 
      if [ "$CBCT_PINCODE" != "" ]; then
        (say_or_beep "Bitte Pin eingeben.")&
        return 1;      
      else
        script_unlock
        redirect "$ADMINSCRIPT" "zurueck zur Hauptauswahl."
        exit;
      fi
    fi

    if [ "$DTMF" = "0" ]; then
      export ACC_MSN="-1"
      (say_or_beep "Interne Verbindung.")
      return 0; 
    else
      let DTMF_ID="$DTMF"
      export ACC_MSN=`eval echo \\$DTMFBOX_ACC${DTMF_ID}_NUMBER`

      if [ "$ACC_MSN" = "" ]; 
      then
         (say_or_beep "Eingabe fehlerhaft. Account 1 bis 10 waehlen oder 0 ." "1")&
         DTMF=""        
      else
         (say_or_beep "Account $DTMF_ID .")
         return 0;
      fi
    fi

  done

}

cbct_ask_number() {


   # generate free-line tone 
   play_tone "freeline"

   DTMF=""
   while [ "$DTMF" = "" ];
   do

    wait_for_dtmf

    $DTMFBOX $TRGCON -hook down
    sleep 1
    play_tone ""

    if [ "$DTMF" = "" ]; then 
      return 1; 
    fi

    if [ "$DTMF" = "*" ]; then 
      (say_or_beep "Bitte Account waehlen.")&
      return 1; 
      break;
    fi

    RESET_NO=`echo "$DTMF" | sed 's/.*\(\*\).*/\1/g'`
    if [ "$RESET_NO" = "*" ];
    then
      $DTMFBOX $TRGCON -hook down
    else

      if [ "$ACC_MSN" = "-1" ];
      then

        # make internal call (and change scriptfile)       
        TRGCON=`$DTMFBOX $SRC_CON -call $SRC_NO $DTMF $DTMFBOX_CAPI_INTERNAL -scriptfile "$CBCTCALLSCRIPT"`

      else

        # make external call (and change scriptfile)
        TRGCON=`$DTMFBOX $SRC_CON -call $ACC_MSN $DTMF -scriptfile "$CBCTCALLSCRIPT"`
      fi

      export TRGCON=$TRGCON
      export ACC_MSN=$ACC_MSN

    fi
    DTMF=""

   done
}

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="CBCT"
  . $USERSCRIPT
  if [ "$?" = "1" ]; then exit 1; fi
fi


# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_admin.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ];
then 
  $CBCTSCRIPT "DTMF" "$TYPE" "$IN_OUT" "$SRC_CON" "$DST_CON" "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF" &
fi

# --------------------------------------------------------------------------------
# CONFIRMED-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "CONFIRMED" ];
then
  $CBCTSCRIPT "DTMF" "$TYPE" "$IN_OUT" "$SRC_CON" "$DST_CON" "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF" &
fi

# --------------------------------------------------------------------------------
# DTMF-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DTMF" ]; 
then

  if [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.lock" ]; then exit; fi
  script_lock

  # load cb/ct settings
  search4msn 

  if [ "$CBCT_ACTIVE" = "0" ];
  then
    script_unlock
    redirect "$ADMINSCRIPT" "Koolfruh ist nicht aktiv."
    exit 1;
  fi

  # no pincode for callthrough? create pinfile...
  if [ "$CBCT_PINCODE" = "" ];
  then
    echo "NOPIN" > "$PINFILE"
    (say_or_beep "Account 1 bis 10 waehlen oder 0 fuer interne Verbindung.")&
  else
    (say_or_beep "Koolfruh. Bitte Pin eingeben.")&
  fi

  ret="0"

  # -----------------------------------------------------------
  # ASK: PIN
  # -----------------------------------------------------------
  while [ "$ret" = "0" ]; 
  do
    cbct_ask_pin
    ret="$?"
    if [ "$ret" = "1" ]; then break; fi

    # -----------------------------------------------------------
    # ASK: ACCOUNT
    # -----------------------------------------------------------
    while [ "$ret" = "0" ];
    do
      cbct_ask_account
      ret="$?"
      if [ "$ret" = "1" ]; then break; fi

      # -----------------------------------------------------------
      # ASK: NUMBER
      # -----------------------------------------------------------
      while [ "$ret" = "0" ];
      do
        cbct_ask_number
        ret="$?"
        if [ "$ret" = "1" ]; then break; fi        

      done
      ret="0"
      # END - ASK: NUMBER

    done
    ret="0"
    # END - ASK: ACCOUNT

  done
  ret="0"
  # END - ASK: PIN

  script_unlock
  redirect "$ADMINSCRIPT" "zurueck zur Hauptauswahl."
fi


# --------------------------------------------------------------------------------
# DISCONNECT-EVENT
# --------------------------------------------------------------------------------
#if [ "$EVENT" = "DISCONNECT" ];
#then
#  script_unlock
#fi
