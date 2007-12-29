#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - answering machine idle script
# --------------------------------------------------------------------------------

# Write PID to file (for killing by disconnect)
echo "$$" > $DTMFBOX_PATH/tmp/script_am_$SRC_CON.pid

# *ringing wait*
sleep $RINGTIME

# Answer call
$DTMFBOX $SRC_CON -hook up

# Is announcement an url?
IS_URL_ANNOUNCEMENT=`echo "$ANNOUNCEMENT" | sed 's/^http:\/\/.*$/OK/g' | sed 's/^ftp:\/\/.*$/OK/g'` 
IS_URL_ANNOUNCEMENT_END=`echo "$ANNOUNCEMENT_END" | sed 's/^http:\/\/.*$/OK/g' | sed 's/^ftp:\/\/.*$/OK/g'` 

PLAY_FIFO="/var/tmp/$SRC_CON-playfifo"
REC_FIFO="/var/tmp/$SRC_CON-recfifo"

# remove (old) fifos
if [ -p "$PLAY_FIFO" ]; then rm "$PLAY_FIFO"; fi
if [ -p "$REC_FIFO" ]; then rm "$REC_FIFO"; fi

# create (new) fifos
$MKFIFO "$PLAY_FIFO"
$MKFIFO "$REC_FIFO"

# Play announcement and record after that ..
if [ "$RECORD" = "LATER" ] || [ "$RECORD" = "OFF" ]; 
then

  # play announcement
  if [ "$ANNOUNCEMENT" != "" ]; then

    if [ "$IS_URL_ANNOUNCEMENT" = "OK" ];
    then
      # stream file from url       
      $WGET -q -O - "$ANNOUNCEMENT" > "$PLAY_FIFO" &
      $DTMFBOX $SRC_CON -play "$PLAY_FIFO" hz=8000 mode=stream
    else      
      # play file from local path
      $DTMFBOX $SRC_CON -play "$ANNOUNCEMENT"
    fi

  else
    # no announcement! Play beep and wait ~10 sec...
    play_tone "notok"
    sleep 3
    play_tone "notok"
    sleep 3
    play_tone "notok"
    sleep 3
  fi

  # beep-tone after announcement?
  if [ "$BEEP" = "1" ]; then
   play_tone "beep"
  fi

# .. or play announcement and record immediately
else

  if [ "$ANNOUNCEMENT" != "" ];
  then
    if [ "$IS_URL_ANNOUNCEMENT" = "OK" ];
    then
      # stream file from url       
      $WGET -q -O - "$ANNOUNCEMENT" > "$PLAY_FIFO" &
      $DTMFBOX $SRC_CON -play "$PLAY_FIFO" hz=8000 mode=stream,thread
    else      
      # play file from local path
      $DTMFBOX $SRC_CON -play "$ANNOUNCEMENT" -mode=thread
    fi  
  else
    # no announcement! Play beep and wait ~10 sec...
    play_tone "notok"
    sleep 3
    play_tone "notok"
    sleep 3
    play_tone "notok"
    sleep 3
  fi
fi

# record now !
if [ "$RECORD" != "OFF" ]; 
then

  # create directory (if not exist)
  if [ ! -d "$DTMFBOX_PATH/record/$ACC_NO" ]; then mkdir -p "$DTMFBOX_PATH/record/$ACC_NO"; fi

  if [ "$FTP_ACTIVE" = "1" ];
  then

    # stream raw data to ftp
    $FTPPUT -u "$FTP_USER" -p "$FTP_PASS" -P "$FTP_PORT" "$FTP_SERVER" "$FTP_PATH/$RECFILE_UNIQUE_FTP" "$REC_FIFO" &
    $DTMFBOX $SRC_CON -record "$REC_FIFO" mode=stream hz=8000 &

    # create local "pseudo" file
    RECFILE_UNIQUE=`echo "$RECFILE_UNIQUE" | sed -e 's/\.wav/\.raw/g'`
    echo > "$RECFILE_UNIQUE"

  else

    # record to local file
    $DTMFBOX $SRC_CON -record "$RECFILE"

  fi


  # Use record timeout? 
  if [ "$TIMEOUT" != "0" ]
  then

    # record waiting time
    sleep $TIMEOUT
    
    # stop fifo-recordblock (if not already done)
    if [ -p "$REC_FIFO" ];
    then
      cat "$REC_FIFO" >/dev/null &
      echo > "$REC_FIFO" &
    fi

    # stop recording
    if [ "$RECORD" != "OFF" ]; 
    then
      $DTMFBOX $SRC_CON -stop record
    fi

    if [ "$ANNOUNCEMENT_END" != "" ];
    then

      if [ "$IS_URL_ANNOUNCEMENT_END" = "OK" ];
      then
        # stream file from url       
        $WGET -q -O - "$ANNOUNCEMENT_END" > "$PLAY_FIFO" &
        $DTMFBOX $SRC_CON -play "$PLAY_FIFO" mode=stream hz=8000
      else
        # play from local path
        $DTMFBOX $SRC_CON -play "$ANNOUNCEMENT_END"
      fi
    fi

    # hook down
    $DTMFBOX $SRC_CON -hook down
  fi

# no recording? Hook down!
else
  $DTMFBOX $SRC_CON -hook down
fi

return 1
