#!/var/tmp/sh

EVENT="$1"
REMOTE_ADDR="$2"
REMOTE_RTP="$3"
let LOCAL_RTP_PLAY=$4
let LOCAL_RTP_REC=$4+2
DTMFBOX_PATH="$5"
SRC_NO="$6"
TRG_NO="$7"
CTRL="$8"

DTMFBOX="dtmfbox"
CONFILE="$DTMFBOX_PATH/tmp/webphone"
PATH=$PATH:$DTMFBOX_PATH

dtmfbox_call() {
  CON=`$DTMFBOX -call "$SRC_NO" "$TRG_NO" $CTRL`
  if [ "$CON" != "" ];
  then
    echo "$CON" > "$CONFILE"    
    sleep 1
    $DTMFBOX $CON -record $REMOTE_ADDR:$REMOTE_RTP rtp=$LOCAL_RTP_PLAY
  	$DTMFBOX $CON -playthread $REMOTE_ADDR:$REMOTE_RTP rtp=$LOCAL_RTP_REC
  fi
}

dtmfbox_hangup() {
  if [ -f "$CONFILE" ];
  then
    CON=`cat "$CONFILE"`
    if [ "$CON" != "" ];
    then
      $DTMFBOX $CON -hook down
    fi
    rm "$CONFILE" 2>/dev/null
  fi
}

if [ "$EVENT" = "CALL" ];
then
  dtmfbox_hangup
  dtmfbox_call
fi

if [ "$EVENT" = "HANGUP" ];
then
  dtmfbox_hangup
fi

