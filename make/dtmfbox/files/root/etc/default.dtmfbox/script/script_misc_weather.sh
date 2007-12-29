#!/bin/sh
# -------------------------------------------------------------------
# dtmfbox - weather forcast
# -------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# variables
URL1="http://pda.wetteronline.de/pda/plz?L=de&tmsid=____&PLZ=$DTMFBOX_INFO_WEATHER_PLZ"
URL2="http://pda.wetteronline.de/pda/bio?PDA=&PLZ=&CREG=$DTMFBOX_INFO_WEATHER_POS"
WEATHER="$DTMFBOX_PATH/tmp/weather.txt"

weather_forcast() {

# create sed files
. $SEDSCRIPT
sed_html2txt
sed_weather

if [ -f "$WEATHER" ]; then rm "$WEATHER"; fi

# Vorhersage
if [ "$1" = "forcast" ];
then
  if [ "$DTMFBOX_INFO_WEATHER_PLZ" = "" ];
  then
    say_or_beep "Es wurde keine Postleitzahl hinterlegt!" "1"
  else  
    echo "Wetter vorher sage fuer " > "$WEATHER"
    wget -O - "$URL1" | sed -n -f "$SED_HTML2TXT" | sed -n -f "$SED_WEATHER" >> "$WEATHER"
  fi

# Biowetter
else
  
  if [ "$DTMFBOX_INFO_WEATHER_POS" = "" ];
  then
    say_or_beep "Es wurde keine Richtung hinterlegt!" "1"
  else  
    echo "" > "$WEATHER"
    wget -O - "$URL2" | sed -n -f "$SED_HTML2TXT" | sed -n -f "$SED_WEATHER" | sed '3,3s/ /. Im Einzelnen: /' >> "$WEATHER"
  fi
fi

# say...
if [ -f "$WEATHER" ]; then
  say_or_beep "`cat $WEATHER`"
fi

exit

}

# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_main.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ]; 
then 
    say_or_beep "1 Wetter vorher sage. 2 Bieoo wetter."
fi

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="MISC_WEATHER"
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
      # 1 = Weather forcast
      # -----------------------------
      1)
         weather_forcast "forcast"
      ;;

      # -----------------------------
      # 2 = Bio weather
      # -----------------------------
      2)
        weather_forcast "bio"
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


