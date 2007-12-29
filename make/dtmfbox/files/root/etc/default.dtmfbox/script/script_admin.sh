#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - administration script
# --------------------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_main.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ]; 
then 
    say_or_beep "1 Anrufbeantworter. 2 DTMF Befehle. 3 Koolfruh. 4 Sonstiges."
fi

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="ADMIN"
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
      # 1 = Answering machine
      # -----------------------------
      1)
         CHANGE_SCRIPT="$AMSCRIPT"
      ;;

      # -----------------------------
      # 2 = DTMF commands
      # -----------------------------
      2)
         CHANGE_SCRIPT="$DTMFSCRIPT"
      ;;

      # -----------------------------
      # 3 = Callthrough
      # -----------------------------
      3)
         CHANGE_SCRIPT="$CBCTSCRIPT"
      ;;

      # -----------------------------
      # 4 = Information
      # -----------------------------
      4)
         CHANGE_SCRIPT="$MISCSCRIPT"
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


