#!/bin/sh
# -------------------------------------------------------------------
# dtmfbox - fritzbox infos
# -------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_main.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ]; 
then 
    say_or_beep "1 Ei,Pi Adresse, 2 letzter Ribuht, 3 Uhrzeit."
fi

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="MISC_FRITZBOX"
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
      # 1 = IP address
      # -----------------------------
      1)
		say_or_beep "Ihre Ei,Pi Adresse lautet: `showdsldstat | grep '0: ip' |  sed -r 's/.*ip.(.*)\/.*mtu.*/\1/g' | sed 's/\./ , - /g'`"
      ;;

      # -----------------------------
      # 2 = last reboot
      # -----------------------------
      2)
        IS_MIN=`uptime | sed -r 's/.*up (.*) min.*$/OK/g'`
        IS_DAY=`uptime | sed -r 's/.*up (.*) day.*$/OK/g'`
        if [ "$IS_MIN" = "OK" ] && [ "$IS_DAY" != "OK" ]; 
        then
          NO=`uptime | sed -r 's/.*up (.*) min.*$/\1/g'`
          FRMT=" Minuten "
        else
          if [ "$IS_DAY" = "OK" ];
          then        
            NO=`uptime | sed -r 's/.*up (.*) day.*$/\1/g'`
            if [ "$NO" = "1" ]; then FRMT=" einem Tag "; NO=""; else FRMT=" Tagen "; fi
          else
            NO=`uptime | sed -r 's/.*up (.*):.*:.*/\1/g'`                        
            NO2=`uptime | sed -r 's/.*up .*:(.*),.*:.*/\1/g'`                        
            NO=`echo "$NO" | sed -r 's/0(.)/\1/g'`
            NO2=`echo "$NO2" | sed -r 's/0(.)/\1/g'`
            if [ "$NO" = "1" ]; then FRMT=" einer Stunde "; NO=""; else FRMT=" Stunden "; fi
            if [ "$NO2" = "1" ]; then FRMT2=" einer Minute "; NO2=""; else FRMT2=" Minuten "; fi            
            NO="$NO $FRMT und $NO2 $FRMT2"
            FRMT=""; FRMT2=""
          fi
        fi

        say_or_beep "Vor $NO $FRMT war der letzte Ribuht."
      ;;

      # -----------------------------
      # 3 = current time
      # -----------------------------
      3)
        say_or_beep "Es ist: `date +\"%H Uhr %M .\"`"        
      ;;

      # -----------------------------
      # * = back to main menu
      # -----------------------------
      "*")
        # change scriptfile
        redirect "$MISCSCRIPT" "zurueck zu Sonstiges."
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


