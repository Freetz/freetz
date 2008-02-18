#!/var/tmp/sh
##################################################################################
## dtmfbox - Callback / Callthrough script
##################################################################################
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

menue_ansage() {
  display_text "Callthrough" &
  say_or_beep "`SPEECH_INTERNAL_3`" 
}

##################################################################################
## pincode check
##################################################################################
cbct_ask_pin() {

  DTMF=""
  if [ "$CBCT_PINCODE" != "" ];
  then

    while [ "$DTMF" != "$CBCT_PINCODE#" ];
    do
      . "$SCRIPT_WAITEVENT" "GETMORE" "#" "*"
      if [ "$EVENT" = "DISCONNECT" ] || [ "$EVENT" = "" ]; then disconnect; exit; fi

      if [ "$DTMF" = "*" ]; then 
        return 1; 
      fi

      if [ "$DTMF" = "$CBCT_PINCODE#" ]; then 
        break; 
      fi

      (say_or_beep "Pin fehlerhaft!")&
      DTMF=""
    done

    (say_or_beep "Pin akzeptiert. Bitte Ehkaunt waehlen.")&
  fi
}

##################################################################################
## ask for account
##################################################################################
cbct_ask_account() {

  DTMF=""
  while [ "$DTMF" = "" ];
  do
    . "$SCRIPT_WAITEVENT" "GETMORE" "#" "*"
    if [ "$EVENT" = "DISCONNECT" ] || [ "$EVENT" = "" ]; then disconnect; exit; fi

    if [ "$DTMF" = "*" ]; then 
      if [ "$CBCT_PINCODE" != "" ]; then
        (say_or_beep "Bitte Pin eingeben.")&
        return 1;      
      else        
        return 2;   # back to script_internal.sh !
      fi
    fi

    if [ "$DTMF" = "0#" ]; then
      export ACC_MSN="-1"
      (say_or_beep "Interne Verbindung.")
      return 0; 
    else
      let DTMF_ID=`echo "$DTMF" | sed 's/#//g'`
      export ACC_MSN=`eval echo \\$DTMFBOX_ACC${DTMF_ID}_NUMBER`

      if [ "$ACC_MSN" = "" ]; 
      then
         (say_or_beep "Eingabe fehlerhaft. Aekaunt 1 bis 10 waehlen oder 0 ." "1")&
         DTMF=""        
      else
         (say_or_beep "Aekaunt $DTMF_ID .")
         return 0;
      fi
    fi

  done

}

##################################################################################
## ask for number
##################################################################################
cbct_ask_number() {

   # generate free-line tone 
   play_tone "freeline"

   DTMF=""
   while [ "$DTMF" = "" ];
   do

    . "$SCRIPT_WAITEVENT" "GETMORE" "#" "*"

    # hook down previous call!!
    $DTMFBOX $TRG_CON -hook down

    if [ "$EVENT" = "DISCONNECT" ] || [ "$EVENT" = "" ]; then disconnect; exit; fi

    if [ "$DTMF" = "*" ]; then 
      play_tone ""
      (say_or_beep "Bitte Aekaunt waehlen.")&
      return 1; 
    fi

    RESET_NO=`echo "$DTMF" | sed 's/.*\(\*\).*/\1/g'`  
    if [ "$RESET_NO" = "*" ];
    then
      # just reset number...  
      play_tone "freeline"
      TRG_CON=""       
    else
      TRG_NO=`echo "$DTMF" | sed 's/#//g'`

      # make call and connect with current
      if [ "$TRG_NO" != "" ];
      then
        play_tone ""
        if [ "$ACC_MSN" = "-1" ];
        then
          # make internal call (and change scriptfile)       
          TRG_CON=`$DTMFBOX $SRC_CON -call $SRC_NO $TRG_NO $DTMFBOX_CAPI_INTERNAL`
        else
          # make external call (and change scriptfile)
          TRG_CON=`$DTMFBOX $SRC_CON -call $ACC_MSN $TRG_NO`
        fi
      else
        # no number entered...
        play_tone "freeline"
        TRG_CON=""       
      fi
 
      if [ "$TRG_CON" != "" ];
      then
        $DTMFBOX $TRG_CON -scriptfile "$SCRIPT_CBCT" -delimiter "poundkey"     
      fi     
    fi
    DTMF=""

   done
}

##################################################################################
## STARTUP
##################################################################################
if [ "$EVENT" = "STARTUP" ];
then

  if [ "$CBCT_ACTIVE" = "0" ];
  then    
    display_text "Callthrough nicht aktiv!" &
    say_or_beep "Koolfruh ist nicht aktiv." "1"
    dtmfbox_change_script "$SRC_CON" "$SCRIPT_INTERNAL" "none"
    return 1;
  else
    menue_ansage

    # no pincode for callthrough?
    if [ "$CBCT_PINCODE" = "" ];
    then
      (say_or_beep "Aekaunt 1 bis 10 waehlen oder 0 fuer interne Verbindung.")&
    else
      (say_or_beep "Bitte Pin eingeben.")&
    fi

  fi
fi


##################################################################################
## LOOP
##################################################################################
ret="0"

# ASK: PIN
while [ "$ret" = "0" ]; 
do
  cbct_ask_pin
  ret="$?"
  if [ "$ret" = "1" ]; then break; fi

  # ASK: ACCOUNT
  while [ "$ret" = "0" ];
  do
    cbct_ask_account
    ret="$?"
    if [ "$ret" = "1" ]; then break; fi

    # ASK: NUMBER
    while [ "$ret" = "0" ];
    do
      cbct_ask_number
      ret="$?"
      if [ "$ret" = "1" ]; then break; fi        
    done
    if [ "$ret" = "1" ]; then ret="0"; fi
    # END - ASK: NUMBER

  done
  if [ "$ret" = "1" ]; then ret="0"; fi
  # END - ASK: ACCOUNT

done
if [ "$ret" = "1" ]; then ret="0"; fi
# END - ASK: PIN

# back to internal script
dtmfbox_change_script "$SRC_CON" "$SCRIPT_INTERNAL" "none"
