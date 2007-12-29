#!/bin/sh
# ------------------------------------------------------------------------
# dtmfbox - anwering machine administration
# ------------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# ------------------------------------------------------------------------
# Play a wave file at position (1# - xxx#)
# ------------------------------------------------------------------------
play_message() {

  let i=1;
  found=0;
    
  for file in `find $DTMFBOX_PATH/record/$ACC_NO/*`
  do
    # search file (by no.)
    if [ "$i" = "$DTMF" ];
    then
      found=1
      break 1
    fi	  
 
    let i=i+1
  done

  # Play file, say date!
  if [ "$found" = "1" ]; 
  then	  

    # convert no to words ;)
    F=`echo "$file" | sed -e 's/.*\///g'`
    DD=`echo $F | sed -e 's/......\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
    MM=`echo $F | sed -e 's/...\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
    H=`echo $F | sed -e 's/..........\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
    M=`echo $F | sed -e 's/.............\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
    if [ "$M" = "0" ]; then M=""; fi

    . "$SEDSCRIPT"
    sed_no2word

	DD=`echo "$DD." | sed -n -f "$SED_NO2WORD"`
	MM=`echo "$MM." | sed -n -f "$SED_NO2WORD"`
	MSG_NO=`echo "$DTMF." | sed -n -f "$SED_NO2WORD"`

    is_ftp=`echo $file | sed -e "s/.*raw/OK/g"`
    
    # say ...
    say_or_beep "$MSG_NO Nachricht, am $DD'n $MM'n - um $H Uhr $M ."

    # .. and play!
    if [ "$is_ftp" = "OK" ];
    then      
      PLAYFIFO="/var/tmp/play-fifo-$SRC_CON"
      file=`echo $file | sed "s/.*\///g`

      $MKFIFO "$PLAYFIFO" 2>/dev/null
      $WGET -q -O - "ftp://$FTP_USER:$FTP_PASS@$FTP_SERVER:$FTP_PORT/$FTP_PATH/$file" > "$PLAYFIFO" &
      $DTMFBOX $SRC_CON -play "$PLAYFIFO" hz=8000 mode=stream,thread >/dev/null
    else
      $DTMFBOX $SRC_CON -play $file mode=thread >/dev/null
    fi
    exit 1;
  fi
}


record_announcement() {
   
  say_or_beep "1 Ansage aufnehmen. 2 Endansage aufnehmen. * abbrechen." &

  DTMF=""
  while [ "$DTMF" != "1" ] && [ "$DTMF" != "2" ] && [ "$DTMF" != "3" ] && [ "$DTMF" != "*" ];
  do
   sleep 1
   get_next_dtmf
   if [ "$DTMF" != "" ]; then break; fi
  done

  if [ "$DTMF" = "1" ] || [ "$DTMF" = "2" ];
  then

    # Endansage
    if [ "$DTMF" = "2" ];
    then

      if [ "$FTP_ACTIVE" = "1" ];
      then
		  OLD_ANNOUNCEMENT="$ANNOUNCEMENT"
		  NEW_ANNOUNCEMENT="ftp://$FTP_USER:$FTP_PASS@$FTP_SERVER:$FTP_PORT/$FTP_PATH/announcement_end_${ACC_NO}.raw"
		  NEW_ANNOUNCEMENT_ESC=`echo $NEW_ANNOUNCEMENT | sed 's/\//\\\\\//g'`
          NEW_ANNOUNCEMENT_FILE="announcement_end_${ACC_NO}.raw"
      else
		  OLD_ANNOUNCEMENT="$ANNOUNCEMENT_END"
		  NEW_ANNOUNCEMENT="./play/announcement_end_${ACC_NO}.wav"
		  NEW_ANNOUNCEMENT_ESC=`echo "$NEW_ANNOUNCEMENT" | sed 's/\//\\\\\//g'`
      fi

	  save_settings "DTMFBOX_SCRIPT_ACC${ACC_NO}_ANNOUNCEMENT_END" "$NEW_ANNOUNCEMENT_ESC"

    # Ansage
    else

      if [ "$FTP_ACTIVE" = "1" ];
      then
		  OLD_ANNOUNCEMENT="$ANNOUNCEMENT"
		  NEW_ANNOUNCEMENT="ftp://$FTP_USER:$FTP_PASS@$FTP_SERVER:$FTP_PORT/$FTP_PATH/announcement_${ACC_NO}.raw"
		  NEW_ANNOUNCEMENT_ESC=`echo $NEW_ANNOUNCEMENT | sed 's/\//\\\\\//g'`
          NEW_ANNOUNCEMENT_FILE="announcement_${ACC_NO}.raw"
      else	
		  OLD_ANNOUNCEMENT="$ANNOUNCEMENT"
		  NEW_ANNOUNCEMENT="./play/announcement_${ACC_NO}.wav"
		  NEW_ANNOUNCEMENT_ESC=`echo $NEW_ANNOUNCEMENT | sed 's/\//\\\\\//g'`
	  fi

	  save_settings "DTMFBOX_SCRIPT_ACC${ACC_NO}_ANNOUNCEMENT" "$NEW_ANNOUNCEMENT_ESC"

    fi

    say_or_beep "Die Aufnahme wird nun gestartet."
    play_tone "beep"
    
    if [ "$FTP_ACTIVE" = "1" ];
    then
      # stream raw data to ftp
      REC_FIFO="/var/tmp/$SRC_CON-recfifo-am"
      $MKFIFO "$REC_FIFO"
      $FTPPUT -u "$FTP_USER" -p "$FTP_PASS" -P "$FTP_PORT" "$FTP_SERVER" "$FTP_PATH/$NEW_ANNOUNCEMENT_FILE" "$REC_FIFO" &
      $DTMFBOX $SRC_CON -record "$REC_FIFO" mode=stream hz=8000 &
    else
      $DTMFBOX $SRC_CON -record $NEW_ANNOUNCEMENT
    fi

    sleep 20

    if [ "$FTP_ACTIVE" = "1" ] && [ -p "$REC_FIFO" ];
    then
      cat "$REC_FIFO" >/dev/null &
      $DTMFBOX $SRC_CON -stop record
      rm "$REC_FIFO"
    else
      $DTMFBOX $SRC_CON -stop record 
    fi

    say_or_beep "Aufnahme beendet."

  else
    say_or_beep "abgebrochen!"
  fi

  DTMF=""
}


activate_deactivate() {
  
  OLD_STATUS="$AM"
  if [ "$AM" = "1" ];
  then 
    save_settings "DTMFBOX_SCRIPT_ACC${ACC_NO}_AM" "0"
    say_or_beep "Der Anrufbeantworter ist deaktiviert." "1" &
    AM="0"
  else 
    save_settings "DTMFBOX_SCRIPT_ACC${ACC_NO}_AM" "1"
    say_or_beep "Der Anrufbeantworter ist aktiviert." &
    AM="1"
  fi

}

delete_recordings() {

  say_or_beep "Alle Aufnahmen loeschen mit 1 . * um abzubrechen." &

  DTMF=""
  while [ "$DTMF" != "1" ] && [ "$DTMF" != "2" ] && [ "$DTMF" != "*" ];
  do
   sleep 1
   get_next_dtmf
   if [ "$DTMF" != "" ]; then break; fi
  done

  if [ "$DTMF" = "1" ];
  then

    echo "USER $FTP_USER" >  /var/tmp/nc_ftp_cmd
    echo "PASS $FTP_PASS" >> /var/tmp/nc_ftp_cmd
    echo "CWD $FTP_PATH"  >> /var/tmp/nc_ftp_cmd

    chmod +x /var/tmp/nc_ftp_cmd
        
    FTP_FOUND="0"
    for file in `find $DTMFBOX_PATH/record/$ACC_NO/*`
    do

      # delete remote: 
      filename=`echo $file | sed 's/^.*\/\(.*\..*\)$/\1/g'`
      IS_FTP=`echo $filename | sed 's/^.*\.raw$/FTP/g'`
      if [ "$IS_FTP" ]; then
        FTP_FOUND="1";
        echo "DELE $filename" >> /var/tmp/nc_ftp_cmd        
      fi

      # delete local:
      rm "$file";

    done

    if [ "$FTP_FOUND" = "1" ]; then
      echo "QUIT"  >> /var/tmp/nc_ftp_cmd
      cat /var/tmp/nc_ftp_cmd | $NC $FTP_SERVER:$FTP_PORT;
    fi
    rm /var/tmp/dtmfbox_delete_ftp.sh 2>/dev/null

    say_or_beep "Alle Aufnahmen wurden geloescht!" &

  else
    say_or_beep "abgebrochen!"
  fi
  DTMF=""

}

am_settings() {

  script_lock

  DTMF="0"
  BACK=""

  while [ "$BACK" != "1" ];
  do

    if [ "$DTMF" != "" ]; 
    then
      say_or_beep "Einstellungen. 1 aktivieren, deaktivieren. 2 Ansagen aufnehmen. 3 Aufnahmen loeschen." &
    fi
    DTMF=""

    while [ "$DTMF" != "1" ] && [ "$DTMF" != "2" ] && [ "$DTMF" != "3" ] && [ "$DTMF" != "*" ];
    do
     sleep 1
     get_next_dtmf
     if [ "$DTMF" != "" ]; then break; fi
    done

    # back to anwering machine menue
    if [ "$DTMF" = "*" ];
    then
      BACK="1"
      DTMF=""
    fi

    # Activate / deactivate answering machine (1#)
    if [ "$DTMF" = "1" ]; then
      activate_deactivate
      DTMF=""
    fi

    # Record an announcement (2#)
    if [ "$DTMF" = "2" ]; then
      record_announcement
      DTMF=""
    fi

    # Delete a messages (3#)
    if [ "$DTMF" = "3" ]; then
      delete_recordings
      DTMF=""
    fi

  done

  script_unlock
  say_or_beep "zurueck zum Anrufbeantworter." &
  exit 1;

}

# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_admin.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ];
then 

  search4msn

  let msg=0
  for file in `find $DTMFBOX_PATH/record/$ACC_NO/*`
  do
	let msg=msg+1
  done

  # create text
  if [ "$msg" = "0" ]; then 
	 msg="Sie haben keine neuen Nachrichten."; 
  else
	if [ "$msg" = "1" ]; then 
	   msg="Sie haben eine neue Nachricht."; 
	else
	   msg="Sie haben $msg neue Nachrichten.";
	fi
  fi

  # say no. of messages (or beep)
  (say_or_beep "$msg")&

fi

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="AM_ADMIN"
  . $USERSCRIPT
  if [ "$?" = "1" ]; then exit 1; fi
fi

# --------------------------------------------------------------------------------
# DTMF-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DTMF" ]; 
then 

   # nothing entered?
   if [ "$DTMF" = "" ]; then
     $0 STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF" 
   fi

   # back to script_admin.sh (*#)?
   if [ "$DTMF" = "*" ];
   then
     redirect "$ADMINSCRIPT" "zurueck"
   fi

   search4msn

   # anwering maching settings
   #
   if [ "$DTMF" = "0" ]; then
     am_settings

   # Play recorded messages (1# - xxx#)
   #
   else
     play_message_before
     if [ "$?" = "0" ]; then play_message; fi
     play_message_after
   fi
fi


