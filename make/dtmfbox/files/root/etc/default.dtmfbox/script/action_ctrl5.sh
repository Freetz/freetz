#!/var/tmp/sh
. /var/dtmfbox/script.cfg
. /var/dtmfbox/script/funcs.sh

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

if [ "$ACC_ID" = "-1" ]; then exit 1; fi

get_cfg_value "/var/dtmfbox/dtmfbox.cfg" "acc$ACC_ID" "capi_controller_out"

##################################################################################
## Important! When this account is a capi account (over Ctrl 5), reject the
## first connect!!!! Otherwise there will be a fallback to ISDN/Analog.
##################################################################################
if [ ! -z "$CFG_VALUE" ]; then
	let REJECT_CTRL=$CFG_VALUE
else
	let REJECT_CTRL=0
fi
if [ "$REJECT_CTRL" = "5" ];
then
  echo "Ctrl5-Script: force reject to prevent fallback!"
  $DTMFBOX $SRC_ID -hook reject
  exit 1;
else
  echo "Ctrl5-Script: no reject required!"
fi
