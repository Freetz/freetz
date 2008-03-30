#!/var/tmp/sh
###############################################################################
## ISDN-Mod Addon for dtmfbox
##
## Description:
##
## Redirects an external call to the internal S0 or to a sip uri (voipd).
## A reverse lookup is also implemented (display name on phone).
##
## In your phone you change your receiving phone number to a fake MSN (eg. 601).
## With this script, you redirect the real MSN to the fake MSN.
##
## When you setup an empty voip account in the AVM-Webif, you can also change
## your sending MSN to the fake MSN.
##
## Parameters:
##
## $1 = Account-ID to redirect (1-10)
##		eg.: 1
##
## $2 = The real MSN
##		eg.: 12345
##
## $3 = Receiving number, to redirect an incoming call (fake MSN or SIP-Uri)
##		eg.: 601 or 601@localhost
##
## $4 = Sending number, to redirect an outgoing call (empty VoIP account)
##		eg.: 0#601 (this one is optional!!)
##
## $5 = AVM-WebIf password (when receiving number is a SIP-Uri)
###############################################################################

REAL_ACCID="$1"		# Account ID of REAL MSN
REAL_MSN="$2"		# REAL MSN
TARGET_MSN="$3"		# TARGET FAKE MSN (S0)
SOURCE_MSN="$4"		# SOURCE FAKE MSN (VOIP)
WEBIF_PASSWD="$5"	# AVM-WebIf password

TARGET_CTRL="3"		# Ctrl. 3 (ISDN S0 for INCOMING)
SOURCE_CTRL="5"		# Ctrl. 5 (VoIP for OUTGOING)

NEW_CON_FILE="$DTMFBOX_PATH/tmp/$TARGET_MSN.$SRC_CON"
DISPLAY_FILE="$DTMFBOX_PATH/tmp/$TARGET_MSN_DISPLAY.$SRC_CON"
AM_FILE="./tmp/$SRC_CON.am_pid"
NEWCON_SCRIPT_FILE="$DTMFBOX_PATH/tmp/isdn_mod_script.$SRC_CON"
CONFIRM_FILE="$DTMFBOX_PATH/tmp/$TARGET_MSN_CONFIRMED"

##################################################################
## INCOMING 
##################################################################
if [ "$TARGET_MSN" != "" ] && [ "$REAL_MSN" != "" ];
then

	##################################################################
	## CALLER (EXTERNAL -> DTMFBOX)
	##################################################################
	if [ "$SCRIPT" = "BEFORE_LOAD" ] && [ "$IN_OUT" = "INCOMING" ] && [ "$TYPE" != "USER" ] && [ "$SRC_NO" = "$REAL_MSN" ];
	then
		# make call from REAL_MSN to TARGET_MSN and connect both
		#
		if [ "$EVENT" = "CONNECT" ];
		then
	
			# cut off international prefix and check if caller is anonymous...
			NUMBER=`echo $DST_NO | sed "s/^$DTMFBOX_CAPI_INT_PREFIX\(.*\)$/0\1/g"`
			if [ "$NUMBER" = "anonymous" ]; 
			then 
				NUMBER="0"; 
				CALL_MODE="mode=anonymous"; 
				REVERS="Unbekannter Anrufer";
			else
				CALL_MODE=""
				REVERS=""
			fi
	
			# when $TARGET_MSN is an Uri, make a call via VoIP.
			# Otherwise use controller 3 (internal S0/CAPI ISDN)
			CALL_VOIP=`echo "$TARGET_MSN" | sed 's/.*@.*/OK/'`
			if [ "$CALL_VOIP" = "OK" ]; then TARGET_CTRL=""; fi

			# make the call to internal S0 (CAPI/ISDN)
			# we do this BEFORE the reverse lookup and display the text later (faster)			
			if [ "$CALL_VOIP" != "OK" ];
			then
				NEW_CON=`$DTMFBOX $SRC_CON -call "$NUMBER" "$TARGET_MSN" $TARGET_CTRL $CALL_MODE`
				echo "$NEW_CON" > "$NEW_CON_FILE"
				DST_CON="$NEW_CON"
			fi
	
			# Number revers lookup (isdn_mod_revers1.sh & isdn_mod_revers2.sh)
			# First, $DTMFBOX_PATH/phonebook.txt will be looked up for a number. 
			# When number was not found, the userscript will be called with $SCRIPT="INVERS".
			# When no number was outputed, isdn_mod_revers2.sh will be called (oertliche.de)
			if [ "$REVERS" = "" ] && [ -f "./script/addons/isdn_mod_revers1.sh" ]; then
				REVERS=`. "./script/addons/isdn_mod_revers1.sh" "$NUMBER"`
			fi
			if [ "$REVERS" = "" ] && [ -f "./script/addons/isdn_mod_revers2.sh" ]; then 
				REVERS=`. "./script/addons/isdn_mod_revers2.sh" "$NUMBER"`
			fi

			if [ "$REVERS" != "" ];
			then
				# Display text on phone (via CAPI)
				if [ "$CALL_VOIP" != "OK" ];
				then
					(
						echo "" > "$DISPLAY_FILE"
						while [ -f "$DISPLAY_FILE" ];
						do
							$DTMFBOX $NEW_CON -text "$REVERS"
							sleep 5
						done
					)&		
					echo "$!" > "$DISPLAY_FILE"
	
				# Display text on phone (via VoIP, write first entry into avm phonebook)
				else
					./script/addons/isdn_mod_avm_pb.sh "$WEBIF_PASSWD" "0" "$REVERS" "$NUMBER"
				fi
			fi

			# make the call via VoIP 
			# we do this AFTER reverse lookup, because the phonebook entry has to be written first (slower)
			if [ "$CALL_VOIP" = "OK" ];
			then
				NEW_CON=`$DTMFBOX $SRC_CON -call "$NUMBER" "$TARGET_MSN" $CALL_MODE`
				echo "$NEW_CON" > "$NEW_CON_FILE"
				DST_CON="$NEW_CON"
			fi

		fi
	
		# Caller gets confirmed
		#
		if [ "$EVENT" = "CONFIRMED" ];
		then
	
			# any other script hooked up? then stop ringing!
			NEW_CON=`cat "$NEW_CON_FILE"`
			if [ ! -f "$CONFIRM_FILE.$NEW_CON" ];
			then
				$DTMFBOX $NEW_CON -hook down
			fi

			# stop displaying text on phone!
			if [ -f "$DISPLAY_FILE" ]; then 
				DISPLAY_PID=`cat "$DISPLAY_FILE"`
				kill -9 "$DISPLAY_PID"
				rm "$DISPLAY_FILE"; 
			fi

			# stop answering maching!
			if [ -f "$AM_FILE" ] && [ -f "$CONFIRM_FILE.$NEW_CON" ]; 
			then
			   PID=`cat "$AM_FILE"`
			   if [ "$PID" != "" ] && [ "$PID" != "-1" ] && [ "$PID" != "0" ];
			   then
			     kill -9 $PID
			   fi
			   rm "$AM_FILE" 2>/dev/null
			fi

		fi
	
		# Caller gets disconnected
		#
		if [ "$EVENT" = "DISCONNECT" ];
		then
			# disconnect target call to internal S0
			NEW_CON=`cat "$NEW_CON_FILE"`
			$DTMFBOX $NEW_CON -hook down
	
			if [ -f "$NEW_CON_FILE" ]; then rm "$NEW_CON_FILE"; fi
			if [ -f "$DISPLAY_FILE" ]; then rm "$DISPLAY_FILE"; fi
		fi
	
	fi
	
	
	##################################################################
	## CALL (DTMFBOX -> INTERNAL)
	##################################################################
	if [ "$SCRIPT" = "BEFORE_LOAD" ] && [ "$IN_OUT" = "OUTGOING" ] && [ "$TYPE" != "USER" ] && [ "$DST_NO" = "$TARGET_MSN" ];
	then
	
		# We hooked up. Confirm caller!
		#
		if [ "$EVENT" = "CONFIRMED" ];
		then
			echo "" > "$CONFIRM_FILE.$SRC_CON"
			$DTMFBOX $DST_CON -hook up
			return 1;
		fi
	
		# Play MOH to caller
		#
		#if [ "$EVENT" = "UNCONFIRMED" ];
		#then
		#	if [ -f "$CONFIRM_FILE.$SRC_CON" ];
		#	then
	  	#	  $DTMFBOX $DST_CON -play $DTMFBOX_PATH/../moh.wav
		#	  return 1
		#	fi
		#fi
	
		# We disconnect. Disconnect caller, too!
		#
		if [ "$EVENT" = "DISCONNECT" ];
		then
			if [ -f "$CONFIRM_FILE.$SRC_CON" ];
			then
				$DTMFBOX $DST_CON -hook down
				rm "$CONFIRM_FILE.$SRC_CON"
			fi
		fi	
	fi	
fi


##################################################################
## OUTGOING
##################################################################
if [ "$SOURCE_MSN" != "" ] && [ "$REAL_MSN" != "" ];
then
		
	##################################################################
	## DDI
	##################################################################
	if [ "$SCRIPT" = "FUNCS" ] && [ "$IN_OUT" = "OUTGOING" ] && [ "$TYPE" = "CAPI" ] && [ "$SRC_NO" = "$SOURCE_MSN" ] && [ "$DST_NO" = "$ACC_DDI" ];
	then
		SRC_NO="$REAL_MSN"
		ACC_NO="$REAL_ACCID"
	fi

	##################################################################
	## CALL (DTMFBOX -> EXTERNAL)
	##################################################################
	if [ "$SCRIPT" = "BEFORE_LOAD" ] && [ "$IN_OUT" = "OUTGOING" ] && [ "$TYPE" = "CAPI" ] && [ "$SRC_NO" = "$REAL_MSN" ];
	then
		if [ "$EVENT" = "CONFIRMED" ];
		then  
		  $DTMFBOX $DST_CON -hook up
		fi
		
		if [ "$EVENT" = "DISCONNECT" ];
		then
		  $DTMFBOX $DST_CON -hook down
		fi
	fi

	##################################################################
	## CALLER (INTERNAL -> DTMFBOX)
	##################################################################
	if [ "$SCRIPT" = "FUNCS" ] && [ "$IN_OUT" = "OUTGOING" ] && [ "$TYPE" = "CAPI" ] && [ "$SRC_NO" = "$SOURCE_MSN" ] && [ "$DST_NO" != "$ACC_DDI" ];
	then
		if [ "$EVENT" = "CONNECT" ] && [ "$DST_NO" != "unknown" ];
		then	
			# send alert to phone 
			$DTMFBOX $SRC_CON -hook alert
	
			# make call 
			NEW_CON=`$DTMFBOX $SRC_CON -call "$REAL_MSN" "$DST_NO"`
			DST_CON="$NEW_CON"
		fi
	
		if [ "$EVENT" = "DISCONNECT" ];
		then	
			$DTMFBOX $DST_CON -hook down
		fi
	fi

fi