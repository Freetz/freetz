#!/var/tmp/sh
##################################################################################
## dtmfbox - answering machine idle script
##################################################################################
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

TEMP_AM_PID="./tmp/$SRC_CON.am_pid"

##################################################################################
## Create record filename ($DATE___$SRC_NO___$DST_NO.wav) !! 
##################################################################################
generate_rec_filename() {

  RECFILE_NAME="`echo $SRC_NO-$DST_NO | sed 's/@.*//g' | sed 's/\./_/g' | sed 's/\*//g' | sed 's/#//g'`"
  DATE="`date +'%y-%m-%d'`"
  DATETIME="`date +'%y-%m-%d--%H-%M-%S'`"
  RECFILE_UNIQUE="`echo $DTMFBOX_PATH/record/$ACC_NO/$DATETIME---$RECFILE_NAME.wav`"
  RECFILE_UNIQUE_FTP="`echo $DATETIME---$RECFILE_NAME.raw`"
  RECFILE="`echo $DTMFBOX_PATH/record/$ACC_NO/$DATE---$RECFILE_NAME-$SRC_CON.wav`"
  DATETEXT="`date +'am %d.%m.%y, um %H:%M Uhr.'`"
}

##################################################################################
## create email body and subject
##################################################################################
create_mail() {

cat << EOF > "$DTMFBOX_PATH/tmp/$SRC_CON.mail_subject.txt"
dtmfbox - Anrufbeantworter - von $DST_NO an $SRC_NO
EOF

cat << EOF > "$DTMFBOX_PATH/tmp/$SRC_CON.mail_body.html"
<html>
<head><title>dtmfbox - Anrufbeantworter</title></head>
<body>
<font style="font-family:Arial;font-size:14px">
<h3><b>dtmfbox - Anrufbeantworter</b><br></h3>
Anruf ($TYPE)<br>
von $DST_NO für $SRC_NO<br>
$DATETEXT<br>
</font>
</body>
</html>
EOF

MAIL_SUBJECT=`cat "$DTMFBOX_PATH/tmp/$SRC_CON.mail_subject.txt"`
}

##################################################################################
## mailer-function
##################################################################################
mailer() {

  if [ "$MAIL_ACTIVE" = "1" ]; 
  then

    if [ -f "$RECFILE" ] && [ "$MAIL_TO" != "" ]; 
    then   

      # create mail body & subject
      #       
      create_mail

      # send mail
      #
      /sbin/mailer -s "$MAIL_SUBJECT" \
             -f "$MAIL_FROM" \
             -t "$MAIL_TO" \
             -m "$MAIL_SERVER" \
             -a "$MAIL_USER" \
             -w "$MAIL_PASS" \
             -d "$RECFILE" \
             -i "$DTMFBOX_PATH/tmp/$SRC_CON.mail_body.html"

      # remove temp. files
      rm "$DTMFBOX_PATH/tmp/$SRC_CON.mail_body.html"   2>/dev/null
      rm "$DTMFBOX_PATH/tmp/$SRC_CON.mail_subject.txt" 2>/dev/null

      # delete recording?
      if [ "$MAIL_DELETE" = "1" ];
      then
        rm "$RECFILE"
      fi

    fi
  fi

}

##################################################################################
## check, if the configured timespan is valid
##################################################################################
check_time() {

   let H_START="`echo $ON_AT | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
   let M_START="`echo $ON_AT | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"
   let H_END="`echo $OFF_AT | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
   let M_END="`echo $OFF_AT | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"

   if [ "$M_END" = "0" ]; then
    let M_END=60
   fi
   if [ "$H_END" = "0" ]; then
    let H_END=24
   fi

   let H="`date +'%H' | sed -e 's/^0\(.*\)/\1/g'`"
   let M="`date +'%M' | sed -e 's/^0\(.*\)/\1/g'`"

   ok=0

   if [ $H_START -le $H ] && [ $H -le $H_END ];
   then
     if [ "$H_START" = "$H" ] || [ "$H_END" = "$H" ]; 
     then
       if [ $M_START -le $M ] && [ $M -le $M_END ]; 
       then
         ok=1
       fi
     else
       ok=1
     fi
   fi

   return $ok
}

##################################################################################
## kill this process, when AM pincode was entered (or on hangup)
##################################################################################
kill_process() {
  if [ -f "$TEMP_AM_PID" ]; then
    PID=`cat "$TEMP_AM_PID"`
    if [ "$PID" != "" ] && [ "$PID" != "-1" ] && [ "$PID" != "0" ];
    then
      kill -9 $PID
    fi
    rm "$TEMP_AM_PID" 2>/dev/null
  fi
}

##################################################################################
## main answering machine function
##################################################################################
answering_machine() {

  # redirect anonymous callers only?
  if [ "$UNKNOWN_ONLY" != "0" ];
  then
    . "$SCRIPT_SED"
    sed_tolower

    TMP_DST=`echo "$DST_NO" | sed -e 's/@.*//g' | sed -n -f "$SED_TOLOWER" | sed -e 's/unknown/anonymous/g' -e 's/^anonym$/anonymous/g'`      
    if [ "$TMP_DST" = "" ]; then TMP_DST="anonymous"; fi

    # not anonymous? then exit!
	if [ "$UNKNOWN_ONLY" = "1" ];
	then
	    if [ "$TMP_DST" != "anonymous" ]; then return 1; fi
	fi

	# when anonymous = answer suddenly
	# when not anonymous = answer after timeout
	if [ "$UNKNOWN_ONLY" = "2" ];
	then
	    if [ "$TMP_DST" = "anonymous" ]; then RINGTIME="0"; fi
	fi
  fi

  # timespan valid...?
  check_time; val=$?
  if [ "$val" = "0" ]; then return 1; fi

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
     THREAD=""
  else
     THREAD="&"
  fi

  # play announcement
  if [ "$ANNOUNCEMENT" != "" ];
  then

    if [ "$IS_URL_ANNOUNCEMENT" = "OK" ];
    then
      (
        # stream file from url        
        wget -q -O - "$ANNOUNCEMENT" > "$PLAY_FIFO" &
        $DTMFBOX $SRC_CON -play "$PLAY_FIFO" hz=8000 mode=stream

        # beep-tone after announcement?
        if [ "$BEEP" = "1" ]; then
          play_tone "beep"
        fi
      ) 

    else      
      (
        # play file from local path
        $DTMFBOX $SRC_CON -play "$ANNOUNCEMENT"

        # beep-tone after announcement?
        if [ "$BEEP" = "1" ]; then
         play_tone "beep"
        fi
      ) 
    fi

  else
    # no announcement
	if [ "$BEEP" = "1" ]; then
	 play_tone "beep"
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
          wget -q -O - "$ANNOUNCEMENT_END" > "$PLAY_FIFO" &
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

  # remove pid file
  rm "$TEMP_AM_PID"
}

##################################################################################
## execute user-script, if exist 
##################################################################################
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="AM"
  . "$USERSCRIPT"
  if [ "$?" = "1" ]; then exit 1; fi
fi

##################################################################################
## STARTUP
##################################################################################
if [ "$EVENT" = "STARTUP" ];
then
  generate_rec_filename
  answering_machine &
  echo "$!" > "$TEMP_AM_PID"
fi

##################################################################################
## DTMF-EVENT (pincode check)
##################################################################################
if [ "$EVENT" = "DTMF" ];
then
  if [ "$DTMF" = "$AM_PIN#" ] && [ "$AM_PIN" != "" ];
  then    
     kill_process 
     $DTMFBOX $SRC_CON -stop play all

     generate_rec_filename     
     rm "$RECFILE" 2>/dev/null

     say_or_beep "Pin akzeptiert!"

     # start blocking events
     . "$SCRIPT_WAITEVENT" "START"

     # change to script_internal.sh     
     (dtmfbox_change_script "$SRC_CON" "$SCRIPT_INTERNAL" "none" "")&

     exit 1;
  fi
fi

##################################################################################
## DISCONNECT-EVENT
##################################################################################
if [ "$EVENT" = "DISCONNECT" ];
then
  generate_rec_filename
  kill_process

  if [ -f "$RECFILE" ]; 
  then		

    # Make recordings "unique" (add time)
    mv "$RECFILE" "$RECFILE_UNIQUE"
    RECFILE="$RECFILE_UNIQUE"
	
    # Mailer...
    #
    mailer    

  fi
fi
