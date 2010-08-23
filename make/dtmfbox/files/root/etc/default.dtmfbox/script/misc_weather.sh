#!/var/tmp/sh
. /var/dtmfbox/script.cfg
. /var/dtmfbox/script/funcs.sh

MODE="$1"
SRC_ID="$2"

get_locktempdir
MADPLAY="$MADPLAY_PATH/madplay"
PODCAST_URL="http://www.daserste.de/wetter/xml/audiopodcast.asp"
PODCAST_FILE="$LOCKTEMPDIR/$SRC_ID-weather_podcast.link"
PODCAST_FIFO="$LOCKTEMPDIR/$SRC_ID-weather_podcast.wav"

if [ "$MODE" = "FORCAST" ]; then
	$DTMFBOX $SRC_ID -speak "Wetter vorhersage noch nicht implementiert!"
	exit 1;
fi

if [ "$MODE" = "BIO" ]; then
	$DTMFBOX $SRC_ID -speak "Bieoo wetter noch nicht implementiert!"
	exit 1;
fi

if [ "$MODE" = "PODCAST" ]; then
	# madplay vorhanden?
	if [ ! -f "$MADPLAY" ]; then
		$DTMFBOX $SRC_ID -speak "Maed plaei nicht hinterlegt!"
		exit 1;
	fi

	# Index laden
	wget "$PODCAST_URL" -O - > "$PODCAST_FILE"

	# letzten MP3-Link ausschneiden
	PODCAST_TITLE=`cat "$PODCAST_FILE" | grep "<title>.*</title>" | sed -e 's/.*<title>\(.*\)<\/title>.*/\1/g' | $TAIL -n 1 | sed -e 's/ - / /g' | sed -e 's/Das //g' | sed -e 's/um .*Uhr.*//g'`
	PODCAST_LINK=`cat "$PODCAST_FILE" | grep "<enclosure url=.* type=.*>" | sed -e "s/.*<enclosure url=\"\(.*\)\" type=.*/\1/g"`
	rm "$PODCAST_FILE"

	# podcast abspielen
	if [ "$PODCAST_LINK" != "" ]; then
		rm "$PODCAST_FIFO" 2>/dev/null
		$MKFIFO "$PODCAST_FIFO"
		if [ -p "$PODCAST_FIFO" ]; then
			$DTMFBOX $SRC_ID -stop play all
			wget "$PODCAST_LINK" -O - | $MADPLAY -R 22050 -m -o wave:$PODCAST_FIFO - &
			$DTMFBOX $SRC_ID -playstream "$PODCAST_FIFO" hz=22050 wait_start=999 wait_end=100
			rm "$PODCAST_FIFO"
		fi
	fi
	exit 0;
fi
