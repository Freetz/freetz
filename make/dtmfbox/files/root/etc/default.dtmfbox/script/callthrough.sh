#!/var/tmp/sh
. /var/dtmfbox/script.cfg
. /var/dtmfbox/script/funcs.sh

DTMF="$1"
SRC_ID="$2"
DST_ID="$3"
OWN_ACC_ID="$4"
TRG_ACC_ID="$5"

############################################
# DTMF=* (return to previous menu)
############################################
if [ "$DTMF" = "*" ];
then
  # goto to previous menu
  if [ "$DST_ID" != "-1" ]; then
    $DTMFBOX $DST_ID -hook down
    $DTMFBOX $SRC_ID -goto "menu:callthrough_number($TRG_ACC_ID)"
  else
    $DTMFBOX $SRC_ID -goto "menu:callthrough_account"
  fi
fi

############################################
# DTMF!=* (dial number)
############################################
if [ "$DTMF" != "*" ];
then
  # reset number?
  RESET_NO=`echo "$DTMF" | sed -e 's/.*\*.*/RESET_NO/g'`
  if [ "$RESET_NO" = "RESET_NO" ]; 
  then
    if [ "$DST_ID" != "-1" ]; then $DTMFBOX $DST_ID -hook down; fi
    $DTMFBOX $SRC_ID -speak "Abbruch."
    sleep 1
    $DTMFBOX $SRC_ID -goto "menu:callthrough_number($TRG_ACC_ID)"    
    exit 1
  fi

  # make call!
  NO=`echo "$DTMF" | sed -e 's/#//g'`
  if [ "$DST_ID" != "-1" ]; then $DTMFBOX $DST_ID -hook down; fi  
  
  if [ "$NO" != "" ];
  then
  
   # get number from dtmfbox.cfg  and remove X#... from capi-voip accounts
   get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc$TRG_ACC_ID" "number"
   if [ ! -z "$CFG_VALUE" ]; then					
	CALLBACK_CALLING_ACC_TMP=`echo $CFG_VALUE | sed 's/.*#//g'`						
	get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc$TRG_ACC_ID" "type"
	CFG_VALUE=`echo $CFG_VALUE | sed -e 's/[^a-z]//g'`
	if [ "$CFG_VALUE" = "capi" ] && [ "$CALLBACK_CALLING_CTRL" = "" ]; then
		get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc$TRG_ACC_ID" "capi_controller_out"
		CFG_VALUE=`echo $CFG_VALUE | sed -e 's/[^0-9]//g'`
		CALLBACK_CALLING_CTRL="$CFG_VALUE"
	fi
	TRG_ACC_ID="$CALLBACK_CALLING_ACC_TMP"						
	echo "Callthrough-Script: $TRG_ACC_ID -> $NO (Ctrl: $CALLBACK_CALLING_CTRL)"
    fi

    # make call
    $DTMFBOX $SRC_ID -call "$TRG_ACC_ID" "$NO" "$CALLBACK_CALLING_CTRL"
  else  
    $DTMFBOX $SRC_ID -speak "Bitte Nummer eingeben."
  fi
fi
