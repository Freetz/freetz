#!/var/tmp/sh
. /var/dtmfbox/script.cfg

MODE="$1"
SRC_ID="$2"

parse_main_info() {
  MAIN_TIME="$2, $4"
  MAIN_NAME="$5"
  MAIN_STATUS="$6"
}

MAIL_FILE="$CHECKMAILD_PATH/checkmaild.$MODE"
if [ ! -f "$MAIL_FILE" ];
then
  $DTMFBOX $SRC_ID -speak "Scheck maeil Datendatei nicht gefunden."
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

$DTMFBOX $SRC_ID -speak "$SAY" 
