#!/var/tmp/sh
. /var/dtmfbox/script/funcs.sh

check_callback() {
  let cnt=1
  let ok=1
  while [ "$ok" = "1" ];
  do
	eval CALLBACK="\$CALLBACK${cnt}"
	if [ "$CALLBACK" = "" ]; then break; fi

	SPLIT=`echo $CALLBACK | sed 's/\// /g'`
	let i=0;
	for SPLIT_VAL in $SPLIT;
	do
	  if [ "$i" = "0" ]; then CALLBACK_TRIGGER_NO="$SPLIT_VAL"; fi
	  if [ "$i" = "1" ]; then CALLBACK_CALLING_NO="$SPLIT_VAL"; fi
	  if [ "$i" = "2" ]; then CALLBACK_TRIGGER_ACC="$SPLIT_VAL"; fi
	  if [ "$i" = "3" ]; then CALLBACK_CALLING_ACC="$SPLIT_VAL"; fi
	  if [ "$i" = "4" ]; then CALLBACK_CALLING_CTRL="$SPLIT_VAL"; fi
	  let i=i+1;
	done
	if [ "$CALLBACK_CALLING_NO" = "" ]; then CALLBACK_CALLING_NO="$DST_NO"; fi
	if [ "$CALLBACK_CALLING_ACC" = "" ]; then CALLBACK_CALLING_ACC="$ACC_ID"; fi
	if [ "$CALLBACK_TRIGGER_ACC" = "" ]; then CALLBACK_TRIGGER_ACC="$ACC_ID"; fi

	VALID_CB=`echo $DST_NO | sed s/$CALLBACK_TRIGGER_NO/OK/g`
	if [ "$VALID_CB" = "OK" ];
	then
	 if [ "$CALLBACK_TRIGGER_ACC" = "$ACC_ID" ] || [ "$CALLBACK_TRIGGER_ACC" = "$SRC_NO" ]; then

		# regex: replace number
		CALLBACK_CALLING_NO=`echo $DST_NO | sed "s/$CALLBACK_TRIGGER_NO/$CALLBACK_CALLING_NO/g"`

		# get number from dtmfbox.cfg  and remove X#... from capi-voip accounts
		get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc$CALLBACK_CALLING_ACC" "number"
		if [ ! -z "$CFG_VALUE" ]; then
			CALLBACK_CALLING_ACC_TMP=`echo $CFG_VALUE | sed -e 's/.*#//g'`
			get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc$CALLBACK_CALLING_ACC" "type"
			CFG_VALUE=`echo $CFG_VALUE | sed -e 's/[^a-z]//g'`

			if [ "$CFG_VALUE" = "capi" ] && [ "$CALLBACK_CALLING_CTRL" = "" ]; then
				get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc$CALLBACK_CALLING_ACC" "capi_controller_out"
				CFG_VALUE=`echo $CFG_VALUE | sed -e 's/[^0-9]//g'`
				CALLBACK_CALLING_CTRL="$CFG_VALUE"
			fi

			CALLBACK_CALLING_ACC="$CALLBACK_CALLING_ACC_TMP"
		fi
		echo "CbCt-Script: valid callback - $CALLBACK_CALLING_ACC -> $CALLBACK_CALLING_NO (Ctrl: $CALLBACK_CALLING_CTRL)"

		# Another script already active?
		if [ -f "$ACTION_CONTROL" ]; then
			echo "CbCt-Script: Another script already got the call! Aborting..."
			VALID_CB=""
			exit 1
		fi
		echo "CB" > "$ACTION_CONTROL"
		return 1
	 else
		VALID_CB=""
	 fi
	else
	VALID_CB=""
	fi

	let cnt=cnt+1
  done
}

check_callthrough() {
  let cnt=1
  let ok=1
  while [ "$ok" = "1" ];
  do
	eval CALLTHROUGH="\$CALLTHROUGH${cnt}"
	if [ "$CALLTHROUGH" = "" ]; then break; fi

	SPLIT=`echo $CALLTHROUGH | sed 's/\// /g'`
	let i=0;
	for SPLIT_VAL in $SPLIT;
	do
	  if [ "$i" = "0" ]; then CALLTHROUGH_TRIGGER_NO="$SPLIT_VAL"; fi
	  if [ "$i" = "1" ]; then CALLTHROUGH_TRIGGER_ACC="$SPLIT_VAL"; fi
	  let i=i+1;
	done
	if [ "$CALLTHROUGH_TRIGGER_ACC" = "" ]; then CALLTHROUGH_TRIGGER_ACC="$ACC_ID"; fi

	VALID_CT=`echo $DST_NO | sed s/$CALLTHROUGH_TRIGGER_NO/OK/g`
	if [ "$VALID_CT" = "OK" ];
	then
	if [ "$CALLTHROUGH_TRIGGER_ACC" = "$ACC_ID" ] || [ "$CALLTHROUGH_TRIGGER_ACC" = "$SRC_NO" ]; then
		echo "CbCt-Script: valid callthrough - $CALLTHROUGH_TRIGGER_ACC -> $CALLTHROUGH_TRIGGER_NO"

		# Another script already active?
		if [ -f "$ACTION_CONTROL" ]; then
			echo "CbCt-Script: Another script already got the call! Aborting..."
			VALID_CT=""
			exit 1
		fi
		echo "CT" > "$ACTION_CONTROL"

		$DTMFBOX $SRC_ID -hook up
		$DTMFBOX $SRC_ID -goto "menu:callthrough_pin"
		return 1
	else
		 VALID_CT=""
	fi
	else
	VALID_CT=""
	fi

	let cnt=cnt+1
  done
}

if [ "$EVENT" = "CONNECT" ] && [ "$DIRECTION" = "INCOMING" ];
then
  # remove address from number (voip only)
  if [ "$TYPE" = "VOIP" ];
  then
	 DST_NO=`echo $DST_NO | sed 's/\(.*\)@.*/\1/g'`
  fi

  #############################################
  # Callback
  #############################################
  check_callback
  if [ "$VALID_CB" = "OK" ];
  then
	 exit 1
  fi

  #############################################
  # Callthrough
  #############################################
  check_callthrough
  if [ "$VALID_CT" = "OK" ];
  then
	$DTMFBOX $SRC_ID -hook up
	$DTMFBOX $SRC_ID -goto "menu:callthrough_pin"
	exit 1
  fi
fi


if [ "$EVENT" = "DISCONNECT" ];
then
  if [ -f "$ACTION_CONTROL" ];
  then
	CBCT_TYPE=`cat "$ACTION_CONTROL"`

	# callback on disconnect
	if [ "$CBCT_TYPE" = "CB" ];
	then
	  rm "$ACTION_CONTROL"
	  check_callback
	  if [ "$VALID_CB" = "OK" ];
	  then
		sleep 3
		echo "CbCt-Script: Callback $CALLBACK_CALLING_ACC -> $CALLBACK_CALLING_NO"
		CON_ID=`$DTMFBOX -call "$CALLBACK_CALLING_ACC" "$CALLBACK_CALLING_NO" "$CALLBACK_CALLING_CTRL"`
		$DTMFBOX $CON_ID -goto "menu:callthrough_pin"
		exit 1;
	  fi
	fi
  fi
fi
