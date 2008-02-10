#!/var/tmp/sh
# --------------------------------------------------------------------------------
# dtmfbox - callback-/callthrough-script for calls
# --------------------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# --------------------------------------------------------------------------------
# DISCONNECT-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DISCONNECT" ];
then

  # reverse connection !!
  #
  CON=$DST_CON
  DST_CON=$SRC_CON
  SRC_CON=$CON

  # play freeline tone
  (play_tone "freeline")&

fi

