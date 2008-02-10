#!/var/tmp/sh
##################################################################################
## dtmfbox - Misc.
##################################################################################
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

menue_ansage() {
   display_text "Sonstiges" &
   say_or_beep "`SPEECH_INTERNAL_4`" &
}

#########################################
## STARTUP
#########################################
if [ "$EVENT" = "STARTUP" ]; 
then 
   menue_ansage
fi

##################################################################################
## LOOP
##################################################################################
while [ "1" = "1" ];
do    
  . "$SCRIPT_WAITEVENT" "GET"

  #########################################
  ## DTMF
  #########################################
  if [ "$EVENT" = "DTMF" ]; 
  then 
      if [ "$DTMF" != "*" ];
      then
        CHANGE_SCRIPT=$SCRIPT_INTERNAL_SUB\_4_$DTMF.sh
      else
        CHANGE_SCRIPT=$SCRIPT_INTERNAL
      fi

      # change scriptfile
      #
      if [ -f "$CHANGE_SCRIPT" ]; 
      then
          dtmfbox_change_script "$SRC_CON" "$CHANGE_SCRIPT" "none"
      else
          menue_ansage
      fi
  fi

  #########################################
  # DISCONNECT
  #########################################
  if [ "$EVENT" = "DISCONNECT" ] || [ "$EVENT" = "" ];
  then
    disconnect
    exit
  fi

done



