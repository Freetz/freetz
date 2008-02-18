#!/var/tmp/sh
# -------------------------------------------------------------------
# dtmfbox - checkmaild 
# -------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

menue_ansage() {
  display_text "CheckmailD" &
  say_or_beep "`SPEECH_INTERNAL_4_3`" &
}

parse_main_info() {
  MAIN_TIME="$2, $4"
  MAIN_NAME="$5"
  MAIN_STATUS="$6"
}

read_mail() {
  MAIL_ACC="$1"
  MAIL_FILE="$DTMFBOX_INFO_CHECKMAILD/checkmaild.$MAIL_ACC"
  
  if [ ! -f "$MAIL_FILE" ];
  then
    say_or_beep "Scheck maeil Datendatei nicht gefunden."
    return 1
  fi

  # read first line and output status
  MAIN_INFO=`cat "$MAIL_FILE" | $HEAD -n 1`
  parse_main_info $MAIN_INFO

  let NEW_MAIL=`echo "$MAIN_STATUS" | sed -e 's/\(.*\)\/.*/\1/g' -e 's/00\(.\)/\1/g' -e 's/0\(..\)/\1/g'`
  let OLD_MAIL=`echo "$MAIN_STATUS" | sed -e 's/.*\/\(.*\)/\1/g' -e 's/00\(.\)/\1/g' -e 's/0\(..\)/\1/g'`
  let ALL_MAIL=$NEW_MAIL+$OLD_MAIL

  SAY=""
  if [ "$ALL_MAIL" = "0" ]; then SAY="Sie haben keine I Maeils."; fi
  if [ "$ALL_MAIL" = "1" ]; then SAY="Sie haben eine I Maeil."; fi
  if [ "$SAY" = "" ]; then SAY="Sie haben $ALL_MAIL I Maeils."; fi

  say_or_beep "$SAY" &
  display_text "$MAIN_NAME" "" "1"
  display_text "$MAIN_STATUS $MAIN_TIME" "" "2"

  # read last 10 mails...
  if [ "$DTMFBOX_INFO_CHECKMAILD_FROM" = "1" ] || [ "$DTMFBOX_INFO_CHECKMAILD_SUBJECT" = "1" ];
  then

    let i=10
    let no=1
    while [ $i -ge 1 ];
    do
      MAIL_FROM=`cat "$MAIL_FILE" | sed 's/^|.*|.*|.*|\(.*\)|.*|.*$/\1/g' | $TAIL -n $i | $HEAD -n 1'`
       
      if [ "$MAIL_FROM" != "$MAIN_INFO" ];
      then

        MAIL_TIME=`cat "$MAIL_FILE" | sed 's/^|.*|\(.*\)|\(.*\)|.*|.*|.*$/\1, \2/g' | $TAIL -n $i | $HEAD -n 1'`
        # show no.
        display_text "Mail #$no, $MAIL_TIME" "" "2"

        # show FROM header
        if [ "$DTMFBOX_INFO_CHECKMAILD_FROM" = "1" ];
        then
          display_text "$MAIL_FROM" "SCROLL" "1"
        fi

        # show subject
        if [ "$DTMFBOX_INFO_CHECKMAILD_SUBJECT" = "1" ];
        then
          MAIL_SUBJECT=`cat "$MAIL_FILE" | sed 's/^|.*|.*|.*|.*|\(.*\)|.*$/\1/g' | $TAIL -n $i | $HEAD -n 1'`
          display_text "$MAIL_SUBJECT" "SCROLL" "1"
        fi

        let no=no+1
      fi    

      let i=i-1
    done

  fi
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
 
      1)
        read_mail "0"
      ;;

      2)
        read_mail "1"
      ;;

      3)
        read_mail "2"
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

