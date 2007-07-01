#!/bin/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox v0.3.9 - callback-/callthrough-script for calls (c) 2007 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------

. ./script/script_funcs.sh

# --------------------------------------------------------------------------------
# DISCONNECT-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DISCONNECT" ];
then

  # reverse connections!!
  #
  CON=$DST_CON
  DST_CON=$SRC_CON
  SRC_CON=$CON

  sleep 1

  # beep or say: "Verbindung beendet.", when call disconnects
  #
  say_or_beep "Verbindung beendet." "1"

  # remove con-file
  if [ -f $CONFILE ]; then rm "$CONFILE"; fi

fi

