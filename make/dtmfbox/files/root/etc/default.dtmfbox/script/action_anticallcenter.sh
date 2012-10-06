#!/var/tmp/sh
. /var/dtmfbox/script.cfg

EVENT="$1"
TYPE="$2"
DIRECTION="$3"
SRC_ID="$4"
DST_ID="$5"
SRC_NO="$6"
DST_NO="$7"
ACC_ID="$8"
DTMF="$9"
MODE="$10"

INTERNAL_CTRL=3

# Mode is "DIAL", when user enters phone number and confirms with #
# Look at section "menu:anticallcenter"
if [ "$MODE" = "DIAL" ];
then
	# Is account configured for anticallcenter script?
	eval RELAY_NO="\$ANTICC_ACC${ACC_ID}_RELAYNO"
	if [ "$RELAY_NO" = "" ]; then return 1; fi

	# SIP-call or use ISDN (Ctrl. 3)?
	if [ ! -z `echo "$RELAY_NO" | grep @` ]; then INTERNAL_CTRL=""; fi

	# Make call!
	echo "AntiCallcenter-Script: Make call (Account $ACC_ID)"
	DST_ID=`$DTMFBOX $SRC_ID -call "$DTMF" "$RELAY_NO" $INTERNAL_CTRL`

	# Leave menu ...
	$DTMFBOX $SRC_ID -stop menu

	# Auto hook up/down for both connections
	$DTMFBOX $SRC_ID -hook auto
	$DTMFBOX $DST_ID -hook auto
fi

# Check, if account is configured for anticallcenter script.
# If caller is anonymous (or number shorter then 5 chars),
# redirect call to menu "menu:anticallcenter"
if [ "$DIRECTION" = "INCOMING" ] && [ "$EVENT" = "CONNECT" ];
then
	# Is account configured for anticallcenter script?
	eval RELAY_NO="\$ANTICC_ACC${ACC_ID}_RELAYNO"
	if [ "$RELAY_NO" = "" ]; then return 1; fi

	# Is anonymous or number length <= 4?
	TMP_DSTNO=`echo $DST_NO | sed 's/@.*//g'`
	let DSTLEN=`echo ${#TMP_DSTNO}`

	if [ "$TMP_DSTNO" = "anonymous" ] || [ $DSTLEN -le 4 ];
	then
		if [ -f "$ACTION_CONTROL" ] && [ "$DIRECTION" = "INCOMING" ];
		then
			echo "AntiCallcenter-Script: Another script already got the call! Aborting..."
			return 1
		fi
		echo "ANONYMOUS" > "$ACTION_CONTROL"

		# Confirm call and send caller to [menu:anticallcenter]
		echo "AntiCallcenter-Script: Confirm call (Account $ACC_ID)"
		$DTMFBOX $SRC_ID -hook up
		$DTMFBOX $SRC_ID -goto menu:anticallcenter
		$DTMFBOX $SRC_ID -speak "Bitte Nummer eingeben und mit Raute bestaetigen."

		# Abort any other "relay"-script
		exit 1
        fi
fi
