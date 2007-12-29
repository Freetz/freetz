#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - informations
# --------------------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

WEATHERSCRIPT="$DTMFBOX_PATH/script/script_misc_weather.sh"
FRITZBOXSCRIPT="$DTMFBOX_PATH/script/script_misc_fb.sh"

# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_main.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ]; 
then 
    say_or_beep "1 Fritz Box, - 2 Wetter"
fi

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="MISC"
  . $USERSCRIPT
  if [ "$?" = "1" ]; then exit 1; fi
fi

# --------------------------------------------------------------------------------
# DTMF-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DTMF" ]; 
then 
      CHANGE_SCRIPT=""

      case "$DTMF" in

      # -----------------------------
      # 1 = Fritz Box
      # -----------------------------
      1)
        CHANGE_SCRIPT="$FRITZBOXSCRIPT"
      ;;

      # -----------------------------
      # 2 = Weather
      # -----------------------------
      2)
         CHANGE_SCRIPT="$WEATHERSCRIPT"
      ;;
      
      # -----------------------------
      # * = back to main menu
      # -----------------------------
      "*")
        # change scriptfile
        redirect "$ADMINSCRIPT" "zurueck"
      ;;

      # -----------------------------
      # any other = StartUp-Menu
      # -----------------------------
      *)
         # run admin "custom" script event "STARTUP" (say no. of messages or beep)
         $0 STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF" 
      ;;
      esac

      # change scriptfile
      #
      if [ "$CHANGE_SCRIPT" != "" ]; 
      then

        # change scriptfile
        redirect "$CHANGE_SCRIPT"

        # run startup event
        $CHANGE_SCRIPT STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF"

      fi

    exit 1;
fi



