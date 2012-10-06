#!/var/tmp/sh

TEXT="$1"
SRC_ID="$2"

if [ -z "$TEXT" ] || [ -z "$SRC_ID" ]; then return 1; fi

# check permission
LOCKTEMPDIR=`touch /var/tmp/$SRC_ID-$$.lock 2>&1`
if [ ! -z "$LOCKTEMPDIR" ]; then LOCKTEMPDIR="/tmp"; else LOCKTEMPDIR="/var/tmp"; rm $LOCKTEMPDIR/$SRC_ID-$$.lock; fi

LOCKFILE="$LOCKTEMPDIR/$SRC_ID-espeak.lock"
LOCKCOUNT=`cat $LOCKFILE 2>/dev/null`
if [ -z "$LOCKCOUNT" ]; then let lock_count=0; else let lock_count=$LOCKCOUNT; fi
let lock_count=lock_count+1
echo "$lock_count" > "$LOCKFILE"

FILE="$LOCKTEMPDIR/$SRC_ID-espeak-$$.wav"

cleanup() {
  if [ -p "$FILE" ]; then
    (
     cat "$FILE" > /dev/null 2>/dev/null
    )&
    (
      sleep 3
      killall -9 $! 2>/dev/null
      if [ -f "$FILE" ]; then rm -f "$FILE"; fi
    )&
  fi

  exit 0
}
trap 'cleanup' 1 2 9 15

. /var/dtmfbox/script.cfg

$DTMFBOX $SRC_ID -stop play all
if [ $lock_count -ge 2 ];
then
  sleep 1
fi

LOCKCOUNT_NEW=`cat $LOCKFILE 2>/dev/null`
if [ -z "$LOCKCOUNT_NEW" ]; then let lock_count_new=1; else let lock_count_new=$LOCKCOUNT_NEW; fi
if [ $lock_count_new -le $lock_count ];
then
  rm "$LOCKFILE"
else
  exit 0;
fi

######### WEBSTREAM ESPEAK (8 khz) #########
if [ "$ESPEAK_INSTALLED" = "0" ];
then
  $MKFIFO "$FILE" 2>/dev/null
  if [ -p "$FILE" ]; then
  (
    TEXT=`echo "$TEXT" | sed "s/ /%20/g"`
    wget -q "http://www.v3v.de/speak.php?speech=$TEXT&speed=$ESPEAK_SPEED&pitch=$ESPEAK_PITCH&volume=$ESPEAK_VOLUME&lang=$ESPEAK_LANG%2B$ESPEAK_TYPE&quality=polyphase&tar=0" -q -O - > "$FILE"
    rm "$FILE" 2>/dev/null
  )&
  fi
  $DTMFBOX $SRC_ID -play "$FILE" mode=stream hz=8000 bufsize=1024 wait_start=350 wait_end=25 >/dev/null
fi

######## INSTALLED ESPEAK (16 khz) #########
if [ "$ESPEAK_INSTALLED" = "1" ];
then
  $MKFIFO "$FILE" 2>/dev/null
  if [ -p "$FILE" ]; then
  (
    cd "$ESPEAK_PATH"
    ./speak -v "$ESPEAK_LANG+$ESPEAK_TYPE" -p "$ESPEAK_PITCH" -s "$ESPEAK_SPEED" -a "$ESPEAK_VOLUME" --stdout "$TEXT" > "$FILE"
    rm "$FILE" 2>/dev/null
  )&
  fi
  $DTMFBOX $SRC_ID -play "$FILE" mode=stream hz=22050 bufsize=1024 wait_start=25 wait_end=10 >/dev/null
fi

########## NO ESPEAK - JUST BEEP ###########
if [ "$ESPEAK_INSTALLED" = "2" ];
then
  $DTMFBOX $SRC_ID -tone 400 400 250 2000 32767;
  $DTMFBOX $SRC_ID -tone 800 800 250 2000 32767;
  sleep 1;
  $DTMFBOX $SRC_ID -stop tone
fi

cleanup
return 0
