#!/var/tmp/sh
. /var/dtmfbox/script.cfg

# Load arguments & settings
EVENT="$1"
TYPE="$2"
DIRECTION="$3"
SRC_ID="$4"
DST_ID="$5"
SRC_NO="$6"
DST_NO="$7"
ACC_ID="$8"
DTMF="$9"
DATA="$10"
ACTION_CONTROL="/var/dtmfbox/tmp/$SRC_ID.action_control"

if [ "$TYPE" = "USER" ]; then return 1; fi

run_script() {
	. $1 "$EVENT" "$TYPE" "$DIRECTION" "$SRC_ID" "$DST_ID" "$SRC_NO" "$DST_NO" "$ACC_ID" "$DTMF" "$DATA"
}

# Initialize ACTION_CONTROL file (remove).
# When file exist, some script has taken the control over the connection
if [ "$EVENT" = "CONNECT" ];
then
	if [ -f "$ACTION_CONTROL" ]; then rm "$ACTION_CONTROL"; fi	
fi

if [ "$DIRECTION" = "INCOMING" ]
then
	# Answering machine
	if [ "$EVENT" = "CONNECT" ] || [ "$EVENT" = "DTMF" ] || [ "$EVENT" = "DISCONNECT" ]; then
		run_script "/var/dtmfbox/script/action_am.sh" &		
	fi

	# Callback/Callthrough 
	if [ "$EVENT" = "CONNECT" ] || [ "$EVENT" = "DISCONNECT" ]; then
		run_script "/var/dtmfbox/script/action_cbct.sh" &		
	fi
fi

if [ "$DIRECTION" = "INCOMING" ] || [ "$DIRECTION" = "OUTGOING" ];
then
	(
		# Anti-Callcenter
		run_script "/var/dtmfbox/script/action_anticallcenter.sh"

		# Reverse lookup  (incoming and outgoing action)
		run_script "/var/dtmfbox/script/action_reverse.sh"
	)&
fi
