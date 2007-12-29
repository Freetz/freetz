#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - callback-/callthrough-script for calls
# --------------------------------------------------------------------------------

if [ "$1" = "DTMF" ] && [ "$9" = "" ]; then exit 1; fi

. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="CBCT_CALL"
  . $USERSCRIPT
  if [ "$?" = "1" ]; then exit 1; fi
fi

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

