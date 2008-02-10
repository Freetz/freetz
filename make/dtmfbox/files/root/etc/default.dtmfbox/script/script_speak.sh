#!/var/tmp/sh
##################################################################################
## dtmfbox - speak script
##################################################################################

##################################################################################
## function say_or_beep (espeak/beep.wav) 
## parameter $1="string": words2say
## parameter $2="1": play not-ok beep
## parameter $3="1": ignore espeak (play beep)
## 
## when $BATCHMODE is 1, there is no playback.
##################################################################################

# first of all, stop active playbacks
$DTMFBOX $SRC_CON -stop play

# no speak, when there are more DTMF characters in queue (fast typing)
WAITING_EVENTS=`$HEAD -n 1 "./tmp/$SRC_CON.waitevent-file"`
if [ "$WAITING_EVENTS" != "" ]; then return 1; fi

SAY="$1"
BEEP="$2"
if [ "$3" = "1" ]; then IGNORE_ESPEAK="1"; else IGNORE_ESPEAK="0"; fi

# espeak installed? 
if [ "$DTMFBOX_ESPEAK" = "2" ];
then     
  if [ -f $DTMFBOX_PATH/espeak/speak ]; then cd $DTMFBOX_PATH/espeak; ESPEAK_APP="$DTMFBOX_PATH/espeak/speak"; fi
  if [ -f /usr/bin/speak ]; then ESPEAK_APP="/usr/bin/speak"; fi
  ESPEAK_HZ="16000"
  ESPEAK_BUFFSIZE="6400"
fi

# espeak from webstream?
if [ "$DTMFBOX_ESPEAK" = "1" ]; then 
  SAY=`echo "$SAY" | sed "s/ /%20/g"` 
  ESPEAK_APP="http://www.v3v.de/speak.php";
  ESPEAK_HZ="8000" 
  ESPEAK_BUFFSIZE="6400"
fi

# espeak off, just beep?
if [ "$DTMFBOX_ESPEAK" = "0" ] || [ "$DTMFBOX_ESPEAK" = "" ]; 
then 
  IGNORE_ESPEAK="1"; 
fi

# say ...
if [ "$ESPEAK_APP" != "" ] && [ "$IGNORE_ESPEAK" = "0" ];
then
  
  # Get a random number ;)
  (echo -n "")&
  EPID=$!

  # Create named pipe
  $MKFIFO "/var/tmp/$SRC_CON.espeak_$EPID" 2>/dev/null

  # eSpeak webstream...
  if [ "$DTMFBOX_ESPEAK" = "1" ];
  then
    wget -q "$ESPEAK_APP?speech=$SAY&speed=$DTMFBOX_ESPEAK_SPEED&pitch=$DTMFBOX_ESPEAK_PITCH&volume=100&lang=de%2B$DTMFBOX_ESPEAK_VOICE$DTMFBOX_ESPEAK_VOICE_TYPE&quality=polyphase&tar=0" -q -O -  > "/var/tmp/$SRC_CON.espeak_$EPID" &
    echo $! > "/var/tmp/$SRC_CON.espeak-pid"
    $DTMFBOX $SRC_CON -play "/var/tmp/$SRC_CON.espeak_$EPID" mode=stream hz=$ESPEAK_HZ bufsize=$ESPEAK_BUFFSIZE wait_start=200 wait_end=20 >/dev/null
  fi

  # eSpeak installed...
  if [ "$DTMFBOX_ESPEAK" = "2" ];
  then        
    $ESPEAK_APP -v de+$DTMFBOX_ESPEAK_VOICE$DTMFBOX_ESPEAK_VOICE_TYPE -s $DTMFBOX_ESPEAK_SPEED -p $DTMFBOX_ESPEAK_PITCH --stdout "$SAY" > "/var/tmp/$SRC_CON.espeak_$EPID" &
    echo $! > "/var/tmp/$SRC_CON.espeak-pid"
    $DTMFBOX $SRC_CON -play "/var/tmp/$SRC_CON.espeak_$EPID" mode=stream hz=$ESPEAK_HZ bufsize=$ESPEAK_BUFFSIZE wait_start=25 wait_end=10 >/dev/null
  fi

  rm "/var/tmp/$SRC_CON.espeak_$EPID" 2>/dev/null
  rm "/var/tmp/$SRC_CON.espeak-pid" 2>/dev/null 
  
# no? just beep...
else
    if [ "$BEEP" = "1" ]; 
    then
      # not-ok
      play_tone "notok"
    else
      # ok
      play_tone "ok"
    fi
fi

cd $DTMFBOX_PATH
