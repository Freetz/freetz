#!/var/tmp/sh
. /var/dtmfbox/script.cfg
. /var/dtmfbox/script/funcs.sh

MODE="$1"
SRC_ID="$2"
MADPLAY="$MADPLAY_PATH/madplay"
eval RADIO_STREAM_URL="\$RADIO_STREAM${MODE}"

get_locktempdir
RADIO_STREAM_FIFO="$LOCKTEMPDIR/$SRC_ID-radio_stream-$MODE"


# madplay vorhanden?
if [ ! -f "$MADPLAY" ]; then
	$DTMFBOX $SRC_ID -speak "Maed plaei nicht hinterlegt!"
	exit 1;
fi

# stream hinterlegt?
if [ "$RADIO_STREAM_URL" = "" ];
then
	$DTMFBOX $SRC_ID -speak "Radio sztriem $MODE nicht hinterlegt!"
	exit 1;
fi

# stop all!
$DTMFBOX $SRC_ID -stop play all
sleep 1

# play!
(echo -n "")&
RADIO_STREAM_FIFO="$RADIO_STREAM_FIFO.$!"

$MKFIFO "$RADIO_STREAM_FIFO"
if [ -p "$RADIO_STREAM_FIFO" ];
then
	 wget "$RADIO_STREAM_URL" -O - | $MADPLAY -R 22050 -m -o wave:$RADIO_STREAM_FIFO - &
	 $DTMFBOX $SRC_ID -playstream "$RADIO_STREAM_FIFO" hz=22050 wait_start=100 wait_end=100
	 rm "$RADIO_STREAM_FIFO"
fi
