#!/var/tmp/sh

if [ "$SCRIPT" = "FUNCS" ];
then

  # Eigene Menü-Ansage hinzufügen
  alias SPEECH_INTERNAL_4="echo `SPEECH_INTERNAL_4` 5 Nachrichten."
  alias SPEECH_INTERNAL_4_5="echo 1 Z D F - Heute. 2 Z D F - Jornal."

  #########
  # TEST:
  #########
   rm ./script/script_internal_4_5.sh
  #########

fi

##################################################################
## SCRIPT ERSTELLEN für Menü: 4/5 (Sonstiges/Nachrichten)
##################################################################
if [ ! -f "./script/script_internal_4_5.sh" ];
then
cat << EOF > "./script/script_internal_4_5.sh"
#!/var/tmp/sh
# -------------------------------------------------------------------
# dtmfbox - news 
# -------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "\$?" = "1" ]; then exit 1; fi

play_news() {

  SUB_CMD="\$1"

  if [ ! -f "\$DTMFBOX_INFO_MADPLAY" ];
  then
     say_or_beep "Maed plaei nicht hinterlegt!" "1" &
     return 1
  fi

  if [ "\$SUB_CMD" = "1" ];
  then
    URL=`wget http://content.zdf.de/podcast/zdf_heute/heute_a.xml -O - | grep "<enclosure url=.* type=.*>" | sed -e 's/.*<enclosure url=\"\(.*\)\" length=.*/\1/g' | head -n 1`
    if [ "$URL" != "" ];
    then
       say_or_beep "Z D F - Heute."
    fi
  fi

  if [ "\$SUB_CMD" = "2" ];
  then
    URL=`wget http://content.zdf.de/podcast/zdf_hjo/hjo_a.xml -O - | grep "<enclosure url=.* type=.*>" | sed -e 's/.*<enclosure url=\"\(.*\)\" length=.*/\1/g' | head -n 1`
    if [ "$URL" != "" ];
    then
       say_or_beep "Z D F - Jornal."
    fi
  fi
  
  (
    \$MKFIFO /var/tmp/\$SRC_CON.stream_\$SUB_CMD
    wget "\$URL" -O - | \$DTMFBOX_INFO_MADPLAY -R 22050 -m -o wave:/var/tmp/\$SRC_CON.stream_\$SUB_CMD - &
    \$DTMFBOX \$SRC_CON -playstream /var/tmp/\$SRC_CON.stream_\$SUB_CMD hz=22050 wait_start=999 >/dev/null
    rm /var/tmp/\$SRC_CON.stream_\$SUB_CMD
  ) &
}

menue_ansage() {
  say_or_beep "`SPEECH_INTERNAL_4_5`" &
}

#########################################
# STARTUP
#########################################
if [ "\$EVENT" = "STARTUP" ]; 
then 
    menue_ansage
fi

while [ "1" = "1" ];
do    
  . "\$SCRIPT_WAITEVENT" "GET"

  #########################################
  # DTMF
  #########################################
  if [ "\$EVENT" = "DTMF" ]; 
  then 
      \$DTMFBOX \$SRC_CON -stop play all

      case "\$DTMF" in
 
      1)
        play_news "1" 
      ;;

      2)
        play_news "2"
      ;;

      # -----------------------------
      # * = back to main menu
      # -----------------------------
      "*")
         CHANGE_SCRIPT=\$SCRIPT_INTERNAL_SUB\_4.sh
         dtmfbox_change_script "\$SRC_CON" "\$CHANGE_SCRIPT" "none"
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
  if [ "\$EVENT" = "DISCONNECT" ] || [ "\$EVENT" = "" ];
  then
    disconnect
    exit
  fi

done
EOF
fi
