#!/var/tmp/sh
# -------------------------------------------------------------------
# dtmfbox - fritzbox infos
# -------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

menue_ansage() {
  display_text "Fritz!Box" &
  say_or_beep "`SPEECH_INTERNAL_4_1`" &
}

#########################################
# STARTUP
#########################################
if [ "$EVENT" = "STARTUP" ]; 
then 
    menue_ansage
fi

while [ "1" = "1" ];
do

  . "$SCRIPT_WAITEVENT" "GET"

  #########################################
  # DTMF
  #########################################
  if [ "$EVENT" = "DTMF" ]; 
  then 
      case "$DTMF" in

      # -----------------------------
      # 1 = IP address
      # -----------------------------
      1)
		say_or_beep "Ihre Ei,Pi Adresse lautet: `showdsldstat | grep '0: ip' |  sed -r 's/.*ip.(.*)\/.*mtu.*/\1/g' | sed 's/\./ , - /g'`" &
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

        say_or_beep "Vor $NO $FRMT war der letzte Ribuht." &
      ;;

      # -----------------------------
      # 3 = current time
      # -----------------------------
      3)
        say_or_beep "Es ist: `date +\"%H Uhr %M .\"`" &    
      ;;

      # -----------------------------
      # * = back to main menu
      # -----------------------------
      "*")
         CHANGE_SCRIPT=$SCRIPT_INTERNAL_SUB\_4.sh
         dtmfbox_change_script "$SRC_CON" "$CHANGE_SCRIPT" "none"
         break;
      ;;

      # -----------------------------
      # any other = StartUp-Menu
      # -----------------------------
      *)
        menue_ansage
      ;;
      esac
  fi

  ##############################################################################
  ## DISCONNECT
  ##############################################################################
  if [ "$EVENT" = "DISCONNECT" ] || [ "$EVENT" = "" ];
  then
    disconnect
    exit
  fi

done


