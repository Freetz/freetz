#!/var/tmp/sh
###############################################################################
## Anti-Callcenter Addon for dtmfbox
##
## Description:
## When answering machine is active and the incoming call is "anonymous",
## dtmfbox answers the call and plays a confirm message ($1 or $3).
## After the caller has entered his phone number + #, he gets
## connected with the target phone number.
##
## Parameters:
## $1 = Wave file to play when dtmfbox confirmed the call
## $2 = Wave file to play when caller confirmed (background music)
## $3 = Say something when dtmfbox confirmed the call (Text)
## $4 = Controller for the internal call (3 for ISDN)
##
## Examples:
## ./script/addons/anti_callcenter.sh "$DTMFBOX_PATH/play/confirm.wav" "$DTMFBOX_PATH/play/music.wav" "" "3"
## ./script/addons/anti_callcenter.sh "" "" "Bitte geben Sie ihre Telefonnummer ein und druecken Sie die Raute taste." "3"
###############################################################################
if [ "$SCRIPT" = "AM" ];
then
	
	PLAY_MSG="$1"
    PLAY_MUSIC="$2"
	SAY_MSG="$3"
	CONTROLLER="$4"

	NEWCON_FILE="$DTMFBOX_PATH/tmp/anonymous_mod_con.$SRC_CON"
	NEWCON_SCRIPT_FILE="$DTMFBOX_PATH/tmp/anonymous_mod_script.$SRC_CON"
	CURCON_PLAY="$DTMFBOX_PATH/tmp/anonymous_mod_play.$SRC_CON"
	
	disconnect_me() {
	
	  if [ -f "$NEWCON_FILE" ];
	  then
	    NEW_CON=`cat "$NEWCON_FILE"`
	    if [ "$NEW_CON" != "" ];
	    then
	      $DTMFBOX $NEW_CON -hook down
	    fi
	    rm "$NEWCON_FILE"
	  fi
	
	  rm "$CURCON_PLAY" 2>/dev/null
	  rm "$NEWCON_SCRIPT_FILE" 2>/dev/null
	}
	
	if [ "$IN_OUT" = "INCOMING" ] && [ "$DST_NO" != "anonymous" ];
	then
	  return 0;
	fi
	
	if [ "$IN_OUT" = "INCOMING" ] && [ "$EVENT" = "STARTUP" ] && [ "$DST_NO" = "anonymous" ];
	then
	  RINGTIME="0"
	fi
	
	if [ "$IN_OUT" = "INCOMING" ] && [ "$EVENT" = "CONFIRMED" ] && [ "$DST_NO" = "anonymous" ];
	then  
	  $DTMFBOX $SRC_CON -delimiter "poundkey"

	  if [ "$PLAY_MSG" != "" ];
	  then
		  PLAY_ID=`$DTMFBOX $SRC_CON -play "$PLAY_MSG"`
	  fi

	  if [ "$SAY_MSG" != "" ];
	  then
		(say_or_beep "$SAY_MSG")&
	  fi
	
cat << EOF > "$NEWCON_SCRIPT_FILE"
#!/bin/sh
. ./script/script_funcs.sh
if [ "\$EVENT" = "CONFIRMED" ];
then  
  CURCON_PLAYPID=\`cat "$CURCON_PLAY"\`
  $DTMFBOX \$DST_CON -stop play all
  rm "$CURCON_PLAY" 2>/dev/null
  $DTMFBOX \$DST_CON -stop play all
fi

if [ "\$EVENT" = "DISCONNECT" ];
then
  $DTMFBOX $SRC_CON -hook down
fi
EOF
	  chmod +x "$NEWCON_SCRIPT_FILE"
	  return 1;
	fi
	
	if [ "$IN_OUT" = "INCOMING" ] && [ "$EVENT" = "DTMF" ] && [ "$DST_NO" = "anonymous" ];
	then

	   if [ -f "$NEWCON_SCRIPT_FILE" ] && [ ! -f "$NEWCON_FILE" ];
	   then
	
	     kill_process
	     $DTMFBOX $SRC_CON -stop record
	
	     DTMF=`echo "$DTMF" | sed 's/*//g' | sed 's/#//g'`
	
	     NEW_CON=`$DTMFBOX $SRC_CON -call "#$DTMF" "$SRC_NO" $CONTROLLER`
	     if [ "$NEW_CON" != "" ];
	     then   
	       echo "$NEW_CON" > "$NEWCON_FILE"
	       $DTMFBOX $NEW_CON -scriptfile "$NEWCON_SCRIPT_FILE" -stop play all

		   if [ "$PLAY_MUSIC" != "" ];
		   then
		       (
		         sleep 1
		         while [ "1" = "1" ];
		         do
		           sleep 1
		           if [ ! -f "$CURCON_PLAY" ]; then exit 1; fi
		           $DTMFBOX $SRC_CON -play "$PLAY_MUSIC" 
		           if [ ! -f "$CURCON_PLAY" ]; then exit 1; fi
		         done
		       )&
		       echo "$!" > "$CURCON_PLAY"
		   fi
	     else
	       $DTMFBOX $SRC_CON -hook down
	     fi
	   fi
	
	   exit 1;
	fi
	
	if [ "$IN_OUT" = "INCOMING" ] && [ "$EVENT" = "DISCONNECT" ] && [ "$DST_NO" = "anonymous" ];
	then
	  disconnect_me
	fi
	
fi
