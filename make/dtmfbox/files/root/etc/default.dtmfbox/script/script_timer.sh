#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - callback script for timer events
# --------------------------------------------------------------------------------

EVENT="$1"
SRC_CON="$4"

TIMER_TYPE="$9"
TONE_MODE="$10"
TONE_STEP="$11"
DTMFBOX="$12"
TIMERSCRIPT="$13"
export BATCHMODE="$14"

if [ "$EVENT" = "TIMER" ];
then

  # -------------
  # TONE_TIMER
  # -------------
  if [ "$TIMER_TYPE" = "TONE_TIMER" ];
  then    

    # -------------
    # tone: ok
    # -------------
    if [ "$TONE_MODE" = "ok" ];
    then
      if [ "$TONE_STEP" = "0" ]; then 
        (
        $DTMFBOX $SRC_CON -tone 500 500 250 10000 32767;
        $DTMFBOX $SRC_CON -timer 100 "$TIMER_TYPE $TONE_MODE 1 \"$DTMFBOX\" \"$TIMERSCRIPT\"" mode=msec -scriptfile "$TIMERSCRIPT"
        )&
        exit;
      fi
      if [ "$TONE_STEP" = "1" ]; then 
        (
        $DTMFBOX $SRC_CON -tone 1000 1000 250 10000 32767;
        $DTMFBOX $SRC_CON -timer 100 "$TIMER_TYPE $TONE_MODE 2 \"$DTMFBOX\" \"$TIMERSCRIPT\"" mode=msec -scriptfile "$TIMERSCRIPT"
        )&
        exit;
      fi
      if [ "$TONE_STEP" = "2" ]; then 
        (
        $DTMFBOX $SRC_CON -stop tone
        $DTMFBOX $SRC_CON -stop timer
        )&
        exit;
      fi
    fi

    # -------------
    # tone: notok
    # -------------
    if [ "$TONE_MODE" = "notok" ];
    then
      if [ "$TONE_STEP" = "0" ]; then 
        $DTMFBOX $SRC_CON -tone 1000 1000 250 10000 32767;
        $DTMFBOX $SRC_CON -timer 100 "$TIMER_TYPE $TONE_MODE 1 \"$DTMFBOX\" \"$TIMERSCRIPT\"" mode=msec -scriptfile "$TIMERSCRIPT"
        exit;
      fi
      if [ "$TONE_STEP" = "1" ]; then 
        $DTMFBOX $SRC_CON -tone 500 500 250 10000 32767;
        $DTMFBOX $SRC_CON -timer 100 "$TIMER_TYPE $TONE_MODE 2 \"$DTMFBOX\" \"$TIMERSCRIPT\"" mode=msec -scriptfile "$TIMERSCRIPT"
        exit;
      fi
      if [ "$TONE_STEP" = "2" ]; then 
        $DTMFBOX $SRC_CON -stop tone
        $DTMFBOX $SRC_CON -stop timer
      fi
    fi
  fi


  # -------------
  # SUBMENUE_TIMER
  # -------------
  if [ "$TIMER_TYPE" = "SUBMENUE_TIMER" ];
  then

     export CHANGE_SCRIPT="`cat $TONE_MODE 2>/dev/null`"
     if [ "$CHANGE_SCRIPT" != "" ];
     then      
        $CHANGE_SCRIPT "DTMF" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$TONE_STEP"
     fi
  fi

fi


