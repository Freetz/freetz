#!/var/tmp/sh
. /var/dtmfbox/script/funcs.sh
. /var/dtmfbox/script/am_funcs.sh

# Abort on client connections (registrar-mode)!
if [ "$TYPE" = "USER" ]; then exit 1; fi

get_locktempdir
AM_PID="/var/dtmfbox/tmp/$SRC_ID.am_pid"
PLAY_FIFO="$LOCKTEMPDIR/$SRC_ID.play"
REC_FIFO="$LOCKTEMPDIR/$SRC_ID.record"

# load answering machine settings
load_am_settings "$ACC_ID"

# Kill AM process
kill_process() {
  if [ -f "$AM_PID" ]; then
	PID=`cat "$AM_PID"`
	if [ "$PID" != "" ] && [ "$PID" != "-1" ] && [ "$PID" != "0" ];
	then
	  kill -9 $PID 2>/dev/null
	fi
	rm "$AM_PID" 2>/dev/null
  fi
}

# Generate unique filenames for recording
generate_rec_filename() {

  RECFILE_NAME="`echo $SRC_NO-$DST_NO | sed 's/@.*//g' | sed 's/\./_/g' | sed 's/\*//g' | sed 's/#//g'`"
  DATE="`date +'%y-%m-%d'`"
  DATETIME="`date +'%y-%m-%d--%H-%M-%S'`"
  RECFILE_UNIQUE="`echo $DTMFBOX_PATH/record/$ACC_ID/$DATETIME---$RECFILE_NAME.wav`"
  RECFILE_UNIQUE_FTP="`echo $DATETIME---$RECFILE_NAME.raw`"
  RECFILE="`echo $DTMFBOX_PATH/record/$ACC_ID/$DATE---$RECFILE_NAME-$SRC_ID.wav`"
  DATETEXT="`date +'am %d.%m.%y, um %H:%M Uhr.'`"
}

# eMailer function
mailer() {

  if [ "$AM_MAIL" = "1" ];
  then

	if [ -f "$RECFILE" ] && [ "$AM_MAIL_TO" != "" ] && [ "$AM_MAIL_FROM" != "" ] && [ "$AM_MAIL_SERVER" != "" ];
	then

# mail body & subject
##########################################################################
cat << EOF > "$DTMFBOX_PATH/tmp/$SRC_ID.mail_body.html"
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
AM_MAIL_SUBJECT="dtmfbox - Anrufbeantworter - von $DST_NO an $SRC_NO"
##########################################################################

	  # send email
	  #
	  echo "AM-Script: sending email to $AM_MAIL_TO..."
	  /sbin/mailer -s "$AM_MAIL_SUBJECT" \
			 -f "$AM_MAIL_FROM" \
			 -t "$AM_MAIL_TO" \
			 -m "$AM_MAIL_SERVER" \
			 -a "$AM_MAIL_USERNAME" \
			 -w "$AM_MAIL_PASSWORD" \
			 -d "$RECFILE" \
			 -i "$DTMFBOX_PATH/tmp/$SRC_ID.mail_body.html"

	  # remove body file
	  rm "$DTMFBOX_PATH/tmp/$SRC_ID.mail_body.html"   2>/dev/null
	fi
  fi
}

# Check if scheduled timespan is valid
check_schedule_time() {

  let H_START="`echo $AM_SCHEDULE_START | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
  let M_START="`echo $AM_SCHEDULE_START | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"
  let H_END="`echo $AM_SCHEDULE_END | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
  let M_END="`echo $AM_SCHEDULE_END | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"

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

# AM beep
beep() {
  $DTMFBOX $SRC_ID -tone 800 800 1000 1000 32767
  sleep 1
  $DTMFBOX $SRC_ID -stop tone
}

# Record to file or FTP
record_file() {

 # create directory (if not exist)
 if [ ! -d "$DTMFBOX_PATH/record/$ACC_ID" ]; then mkdir -p "$DTMFBOX_PATH/record/$ACC_ID"; fi

 if [ "$AM_FTP" = "1" ];
 then

   # stream raw data to ftp
   if [ -p "$REC_FIFO" ]; then rm "$REC_FIFO"; fi
   $MKFIFO "$REC_FIFO"

   if [ -p "$REC_FIFO" ];
   then

	 # stream to FTP and send file with mailer
	 if [ "$AM_MAIL" = "1" ];
	 then
	   $DTMFBOX $SRC_ID -record "$RECFILE" &

	 # just stream to FTP
	 else
	   echo "AM-Script: stream to $AM_FTP_SERVER:$AM_FTP_PORT$AM_FTP_PATH"
	   $DTMFBOX $SRC_ID -record "$REC_FIFO" &
	   $FTPPUT -u "$AM_FTP_USERNAME" -p "$AM_FTP_PASSWORD" -P "$AM_FTP_PORT" "$AM_FTP_SERVER" "$AM_FTP_PATH/$RECFILE_UNIQUE_FTP" "$REC_FIFO" &

	   # create local pseudo file
	   RECFILE_UNIQUE=`echo "$RECFILE_UNIQUE" | sed -e 's/\.wav/\.raw/g'`
	   echo > "$RECFILE_UNIQUE"
	 fi

   fi

 else

   # record to local file
   $DTMFBOX $SRC_ID -record "$RECFILE"

 fi
}

# Play file or URL
play_file() {

 PLAY_FILE="$1"
 BEEP="$2"
 IS_URL=`echo "$PLAY_FILE" | sed 's/^http:\/\/.*$/OK/g' | sed 's/^ftp:\/\/.*$/OK/g'`

 if [ "$PLAY_FILE" != "" ];
 then
   if [ "$IS_URL" = "OK" ];
   then
	 (
	   if [ -p "$PLAY_FIFO" ]; then rm "$PLAY_FIFO"; fi
	   $MKFIFO "$PLAY_FIFO"

	   if [ -p "$PLAY_FIFO" ];
	   then
		 wget -q -O - "$PLAY_FILE" > "$PLAY_FIFO" &
		 $DTMFBOX $SRC_ID -play "$PLAY_FIFO" hz=8000 mode=stream wait=100 >/dev/null
		 if [ -p "$PLAY_FIFO" ]; then rm "$PLAY_FIFO"; fi
	   fi
	 )
   else
	 (
	   $DTMFBOX $SRC_ID -play "$PLAY_FILE" >/dev/null
	 )
   fi
 fi

 if [ "$BEEP" = "1" ]; then
   beep &
 fi
}

#############################################################################################################

# Answering-Machine - START
if [ "$EVENT" = "CONNECT" ] && [ "$DIRECTION" = "INCOMING" ] && [ "$AM_ACTIVE" = "1" ];
then

 IS_ANONYMOUS=`echo "$DST_NO" | sed -e 's/@.*//g' | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZÖÄÜ/abcdefghijklmnopqrstuvwxyzöäü/;" | sed -e 's/unknown/anonymous/g' -e 's/^anonym$/anonymous/g'`
 if [ "$IS_ANONYMOUS" = "" ]; then IS_ANONYMOUS="anonymous"; fi

 # Hookup-Type: 0=all, 1=anonymous only, 2=anonymous immediately - others after ringtime
 if [ "$AM_HOOKUP_TYPE" = "1" ] && [ "$IS_ANONYMOUS" != "anonymous" ]; then return 1; fi
 if [ "$AM_HOOKUP_TYPE" = "2" ] && [ "$IS_ANONYMOUS" = "anonymous" ]; then AM_RING_TIME="0"; fi

 # valid timespan?
 check_schedule_time; val=$?
 if [ "$val" = "0" ]; then return 1; fi

 (
   # Another script already active?
   if [ -f "$ACTION_CONTROL" ]; then
	 rm "$AM_PID"
	 echo "AM-Script: Another script already got the call! Aborting..."
	 exit 1
   fi

   echo "AM-Script: waiting $AM_RING_TIME sec..."
   generate_rec_filename

   # wait...
   sleep $AM_RING_TIME

   # Another script already active?
   if [ -f "$ACTION_CONTROL" ]; then
	 rm "$AM_PID"
	 echo "AM-Script: Another script already got the call! Aborting..."
	 exit 1
   fi
   echo "AM" > "$ACTION_CONTROL"

   echo "AM-Script: hook up!"
   $DTMFBOX $SRC_ID -hook up

   # play announcement
   if [ "$AM_RECORD_TYPE" = "0" ]; then
	 THREAD=""
   else
	 THREAD="&"
   fi
   echo "AM-Script: playing $AM_ANNOUNCEMENT_START $THREAD"
   play_file "$AM_ANNOUNCEMENT_START" "$AM_BEEP" $THREAD

   # record message
   if [ "$AM_RECORD_TYPE" != "2" ];
   then
	 echo "AM-Script: recording $RECFILE"
	 record_file
   fi

   # record timeout
   echo "AM-Script: waiting $AM_RECORD_TIME sec..."
   sleep $AM_RECORD_TIME

   # play end announcement (without beep)
   echo "AM-Script: playing $AM_ANNOUNCEMENT_END"
   play_file "$AM_ANNOUNCEMENT_END" "0"

   # hook down
   echo "AM-Script: hook down!"
   $DTMFBOX $SRC_ID -hook down

   rm "$AM_PID"
   exit 1;
  )&

  # save pid of am process
  echo "$!" > "$AM_PID"
  exit 1;
fi


# Answering-Machine - PIN
if [ "$EVENT" = "DTMF" ] && [ "$DIRECTION" = "INCOMING" ] && [ "$AM_ACTIVE" = "1" ] && [ "$AM_MENU" != "" ] && [ "$AM_PIN" != "" ];
then
  if [ "`echo $DTMF | grep $AM_PIN`" != "" ]
  then
	# stop answering machine
	kill_process
	$DTMFBOX $SRC_ID -stop play all
	$DTMFBOX $SRC_ID -stop record

	# delete recording
	generate_rec_filename
	rm "$RECFILE" 2>/dev/null
	sleep 1

	# goto menu
	$DTMFBOX $SRC_ID -goto "$AM_MENU"

	echo "AM-Script: Pin accepted. Goto $AM_MENU"
	exit 1
  fi
fi


# Answering-Machine - END
if [ "$EVENT" = "DISCONNECT" ] && [ "$DIRECTION" = "INCOMING" ] && [ "$AM_ACTIVE" = "1" ];
then
 kill_process
 generate_rec_filename

 # Make recording "unique" (add time)
 if [ -f "$RECFILE" ];
 then
   $DTMFBOX $SRC_ID -stop record

   mv "$RECFILE" "$RECFILE_UNIQUE"
   RECFILE="$RECFILE_UNIQUE"
   echo "AM-Script: successfully recorded to $RECFILE"

   if [ "$AM_MAIL" = "1" ];
   then

	 # also send to FTP?
	 if [ "$AM_FTP" = "1" ];
	 then
	   echo "AM-Script: stream to $AM_FTP_SERVER:$AM_FTP_PORT$AM_FTP_PATH"
	   $FTPPUT -u "$AM_FTP_USERNAME" -p "$AM_FTP_PASSWORD" -P "$AM_FTP_PORT" "$AM_FTP_SERVER" "$AM_FTP_PATH/$RECFILE_UNIQUE_FTP" "$RECFILE"

	   # create local pseudo file
	   RECFILE_UNIQUE=`echo "$RECFILE_UNIQUE" | sed -e 's/\.wav/\.raw/g'`
	   echo > "$RECFILE_UNIQUE"
	 fi

	 # Send mail!
	 mailer

	 # delete recording after mail?
	 if [ "$AM_MAIL_DELETE_AFTER_SEND" = "1" ];
	 then
	   echo "AM-Script: deleting $RECFILE"
	   rm "$RECFILE";
	 fi
   fi
 fi
fi
