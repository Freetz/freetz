#!/var/tmp/sh
# -------------------------------------------------------------------
# dtmfbox - radio streaming 
# -------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

TEMP_STREAMPID="./tmp/$SRC_CON.stream_pid"

menue_ansage() {
  display_text "Radio" &
  say_or_beep "`SPEECH_INTERNAL_4_4`" &
}

kill_stream() {

  if [ -f "$TEMP_STREAMPID" ];
  then
    $DTMFBOX $SRC_CON -stop play all
    PID=`cat "$TEMP_STREAMPID"`
    if [ "$PID" != "" ]; then kill -9 $PID; fi
    rm "$TEMP_STREAMPID"
  fi

}

play_stream() {

  STREAM_NO="$1"
  URL="$2"

  if [ ! -f "$DTMFBOX_INFO_MADPLAY" ];
  then
     say_or_beep "Maed plaei nicht hinterlegt!" "1" &
     return 1
  fi

  if [ "$URL" = "" ];
  then
     say_or_beep "Es wurde kein MP3 sztriem hinterlegt!" "1" &
     return 1
  fi

  (
    display_text "Stream $STREAM_NO" &
    say_or_beep "Radio sztriem $STREAM_NO"
    $MKFIFO /var/tmp/$SRC_CON.stream_$STREAM_NO
    $MKFIFO /var/tmp/$SRC_CON.stream_wget_$STREAM_NO
    (
     wget "$URL" -O - > /var/tmp/$SRC_CON.stream_wget_$1 &
     echo "$!" > "$TEMP_STREAMPID"
     $DTMFBOX_INFO_MADPLAY -R 22050 -m -o wave:/var/tmp/$SRC_CON.stream_$STREAM_NO /var/tmp/$SRC_CON.stream_wget_$1 &
     $DTMFBOX $SRC_CON -playstream /var/tmp/$SRC_CON.stream_$STREAM_NO hz=22050 wait_start=999 >/dev/null
    )
    rm /var/tmp/$SRC_CON.stream_$STREAM_NO
    rm /var/tmp/$SRC_CON.stream_wget_$STREAM_NO
  ) &

  sleep 1
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
  kill_stream

  #########################################
  # DTMF
  #########################################
  if [ "$EVENT" = "DTMF" ]; 
  then 

      case "$DTMF" in
 
      1)
        play_stream "1" "$DTMFBOX_INFO_MADPLAY_STREAM1"
      ;;

      2)
        play_stream "2" "$DTMFBOX_INFO_MADPLAY_STREAM2"
      ;;

      3)
        play_stream "3" "$DTMFBOX_INFO_MADPLAY_STREAM3"
      ;;

      4)
        play_stream "4" "$DTMFBOX_INFO_MADPLAY_STREAM4"
      ;;

      5)
        play_stream "5" "$DTMFBOX_INFO_MADPLAY_STREAM5"
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

