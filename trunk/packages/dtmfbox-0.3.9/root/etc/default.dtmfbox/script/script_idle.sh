#!/bin/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox v0.3.9 - answering machine idle script (c) 2007 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------

# Write PID to file (for killing by disconnect)
echo $$ > $DTMFBOX_PATH/tmp/script_idle_$SRC_CON.pid
sleep $RINGTIME

# Answer call
$DTMFBOX $SRC_CON -hook up

# Play announcement and record after that ..
if [ "$RECORD" = "LATER" ] || [ "$RECORD" = "OFF" ]; 
then

  # play announcement
  if [ "$ANNOUNCEMENT" != "" ]; then
    $DTMFBOX $SRC_CON -play $ANNOUNCEMENT
  fi

  # beep-tone after announcement?
  if [ "$BEEP" = "1" ]; then
    $DTMFBOX $SRC_CON -playthread $WAV_BEEP
  fi

# .. or play announcement and record immediately
else

  $DTMFBOX $SRC_CON -playthread $ANNOUNCEMENT

fi

# record now !
if [ "$RECORD" != "OFF" ]; 
then

  # create directory (if not exist)
  if [ ! -d $DTMFBOX_PATH/record/$SRC_NO ]; then mkdir $DTMFBOX_PATH/record/$SRC_NO; fi

  # record to file
  $DTMFBOX $SRC_CON -record $RECFILE

  # Use record timeout? 
  if [ "$TIMEOUT" != "0" ]
  then
    sleep $TIMEOUT
    $DTMFBOX $SRC_CON -play $ANNOUNCEMENT_END
    $DTMFBOX $SRC_CON -hook down
  fi

# no recording? Hook down!
else

  $DTMFBOX $SRC_CON -hook down

fi

return 1
 