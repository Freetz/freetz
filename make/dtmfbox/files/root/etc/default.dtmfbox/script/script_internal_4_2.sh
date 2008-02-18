#!/var/tmp/sh
##################################################################################
## dtmfbox - weather
##################################################################################
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# variables
URL1="http://pda.wetteronline.de/pda/plz?L=de&tmsid=____&PLZ=$DTMFBOX_INFO_WEATHER_PLZ"
URL2="http://pda.wetteronline.de/pda/bio?PDA=&PLZ=&CREG=$DTMFBOX_INFO_WEATHER_POS"
URL3="http://www.daserste.de/wetter/xml/audiopodcast.asp"
WEATHER="$DTMFBOX_PATH/tmp/weather.txt"

menue_ansage() {
  display_text "Wetter" &
  say_or_beep "`SPEECH_INTERNAL_4_2`" &
}

##################################################################################
## weather forcast function ($1=forcast, $1="bio")
##################################################################################
weather_forcast() {

# create sed files
. $SCRIPT_SED
sed_html2txt
sed_weather

if [ -f "$WEATHER" ]; then rm "$WEATHER"; fi

# Vorhersage
if [ "$1" = "forcast" ];
then
  if [ "$DTMFBOX_INFO_WEATHER_PLZ" = "" ];
  then
    say_or_beep "Es wurde keine Postleitzahl hinterlegt!" "1" &
  else  
    echo "Wetter vorher sage fuer " > "$WEATHER"
    wget -O - "$URL1" | sed -n -f "$SED_HTML2TXT" | sed -n -f "$SED_WEATHER" >> "$WEATHER"
  fi

# Biowetter
else
  
  if [ "$DTMFBOX_INFO_WEATHER_POS" = "" ];
  then
    say_or_beep "Es wurde keine Richtung hinterlegt!" "1" &
  else  
    echo "" > "$WEATHER"
    wget -O - "$URL2" | sed -n -f "$SED_HTML2TXT" | sed -n -f "$SED_WEATHER" | sed '3,3s/ /. Im Einzelnen: /' >> "$WEATHER"
  fi
fi

# say...
if [ -f "$WEATHER" ]; then
  say_or_beep "`cat $WEATHER`" &
fi
}

##################################################################################
## weather forcast (podcast)
##################################################################################
weather_podcast() {

  if [ ! -f "$DTMFBOX_INFO_MADPLAY" ];
  then
     say_or_beep "Maed plaei nicht hinterlegt!" "1" &
     return 1
  fi

  # get weather podcast xml
  wget "$URL3" -O - > "$WEATHER"

  PODCAST_TITLE=`cat "$WEATHER" | grep "<title>.*</title>" | sed -e 's/.*<title>\(.*\)<\/title>.*/\1/g' | $TAIL -n 1 | sed -e 's/ - / /g' | sed -e 's/Das //g' | sed -e 's/um .*Uhr.*//g'`
  PODCAST_LINK=`cat "$WEATHER" | grep "<enclosure url=.* type=.*>" | sed -e "s/.*<enclosure url=\"\(.*\)\" type=.*/\1/g"`

  if [ "$PODCAST_LINK" != "" ];
  then    
    (
      $DTMFBOX $SRC_CON -text "$PODCAST_TITLE"

      $MKFIFO /var/tmp/$SRC_CON.weather_podcast
      wget "$PODCAST_LINK" -O - | $DTMFBOX_INFO_MADPLAY -R 22050 -m -o wave:/var/tmp/$SRC_CON.weather_podcast - &
      $DTMFBOX $SRC_CON -playstream /var/tmp/$SRC_CON.weather_podcast hz=22050 wait_start=999 >/dev/null
      rm /var/tmp/$SRC_CON.weather_podcast 2>/dev/null
    )&
  else
    say_or_beep "Fehler beim Daunload." "1"
  fi
}

#########################################
# STARTUP
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
  # DTMF
  #########################################
  if [ "$EVENT" = "DTMF" ]; 
  then 

      $DTMFBOX $SRC_CON -stop play all

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
      # 3 = Podcast (madplay)
      # -----------------------------
      3)
        weather_podcast
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

