#!/var/tmp/sh

# Temporary files
if [ "$DIRECTION" = "INCOMING" ];
then
	XCON_ID_FILE="/var/dtmfbox/tmp/$SRC_ID.xcon"
	XCON_CF_FILE="/var/dtmfbox/tmp/$SRC_ID.xcon_confirm"
	XCON_DP_FILE="/var/dtmfbox/tmp/$SRC_ID.xcon_display"
	XCON_MP_FILE="/var/dtmfbox/tmp/$SRC_ID.xcon_musicpal"
else
	XCON_ID_FILE="/var/dtmfbox/tmp/$DST_ID.xcon"
	XCON_CF_FILE="/var/dtmfbox/tmp/$DST_ID.xcon_confirm"
	XCON_DP_FILE="/var/dtmfbox/tmp/$SRC_ID.xcon_display"
	XCON_MP_FILE="/var/dtmfbox/tmp/$DST_ID.xcon_musicpal"
fi
if [ -f "$XCON_ID_FILE" ]; then XCON_ID="`cat $XCON_ID_FILE 2>/dev/null`"; else XCON_ID=""; fi

# Variables
INTERNAL_CTRL=3

# Reverse lookup 1 (custom)
# $1=number
reverse_lookup1() {
	if [ "`echo $DST_NO | grep 12345`" != "" ]; then echo "Anruf von 12345!"; fi
}

# Reverse lookup 2 (dasOertliche.de)
# $1=number
reverse_lookup2() {
	number="$1"
	url="http://www2.dasoertliche.de/?form_name=search_inv&page=RUECKSUCHE&context=RUECKSUCHE&action=STANDARDSUCHE&la=de&rci=no&ph=$number"
	temp=$(wget -q -O - "$url" | grep -A 10 class=\"entry)
	name=$(echo "$temp" | sed -n -e 's/<[^<]*>/\ /g; s/^[^a-zA-Z0-9]*//g; 1p')
	addr=$(echo "$temp" | grep "&nbsp" | sed -e 's/ //g; s/&nbsp;/ /g; s/<[^<]*>//g;')
	if [ "$name" != "" ]; then echo "$name"; fi
	#if [ "$addr" != "" ]; then echo -n "-$addr"; fi
}

get_display_text() {
	if [ "$DST_NO" = "anonymous" ] || [ $DST_NO_LEN -le 4 ];
	then
		DISPLAY_TEXT="Unbekannter Anrufer!";
	else
	  	DISPLAY_TEXT=`reverse_lookup1 "$TMP_DSTNO"`
		if [ "$DISPLAY_TEXT" = "" ]; then DISPLAY_TEXT=`reverse_lookup2 "$TMP_DSTNO"`; fi
	fi
}

# Show reverse lookup on phone
show_display_text() {

	touch "$XCON_DP_FILE"

	TMP_DSTNO=`echo $DST_NO | sed 's/@.*//g'`
	let DST_NO_LEN=`echo ${#TMP_DSTNO}`

	get_display_text

	if [ "$DISPLAY_TEXT" != "" ];
	then
		while [ -f "$XCON_DP_FILE" ];
		do
			$DTMFBOX $DST_ID -text "$DISPLAY_TEXT"
			sleep 5
		done
	fi

	rm "$XCON_DP_FILE" 2>/dev/null
}

# Remove temporary files
remove_temporary_files() {
	if [ -f "$XCON_ID_FILE" ]; then rm "$XCON_ID_FILE" 2>/dev/null; fi
	if [ -f "$XCON_CF_FILE" ]; then rm "$XCON_CF_FILE" 2>/dev/null; fi
	if [ -f "$XCON_DP_FILE" ]; then rm "$XCON_DP_FILE" 2>/dev/null; fi
	if [ -f "$XCON_MP_FILE" ]; then rm "$XCON_MP_FILE" 2>/dev/null; fi
}

# On connect
# We make a call to the fake MSN and save the connection id
# After that, we make a reverse lookup and send the result as display message to the phone
if [ "$EVENT" = "CONNECT" ] && [ "$DIRECTION" = "INCOMING" ];
then
	# Initialize
	remove_temporary_files

	# MusicPal (ipc_send)
	if [ ! -z "$MUSICPAL_IP" ] && [ ! -z "$MUSICPAL_PASSWORD" ];
	then
		(
		touch $XCON_MP_FILE
		get_display_text
		if [ -z "$DISPLAY_TEXT" ]; then DISPLAY_TEXT="Von:%20$DST_NO%A7MSN:%20$SRC_NO"; fi
		DISPLAY_TEXT=`echo "$DISPLAY_TEXT" | sed 's/ /%20/g'`
		wget -O - "http://$MUSICPAL_USERNAME:$MUSICPAL_PASSWORD@$MUSICPAL_IP/admin/cgi-bin/ipc_send?show_msg_box%20$DISPLAY_TEXT"
		)&
	fi

	# Is account configured for reverse lookup?
	eval FAKE_MSN="\$REVERS_ACC${ACC_ID}_FAKEMSN"	
	if [ "$FAKE_MSN" = "" ]; then return 1; fi

	# Make call, save returning connection id
	echo "Reverse-Script: Make call (Account $ACC_ID)"
	DST_ID=`$DTMFBOX $SRC_ID -call $DST_NO $FAKE_MSN $INTERNAL_CTRL`
	echo "$DST_ID" > "$XCON_ID_FILE"

	# Auto hook up/down for both connections
	$DTMFBOX $SRC_ID -hook auto
	$DTMFBOX $DST_ID -hook auto

	# Show display text
	show_display_text
fi

# On confirm
# When any another script is already running (answering machine, callthrough,  etc.), then abort.
# Otherwise we take control...
if [ "$EVENT" = "CONFIRMED" ];
then	
	if [ "$DIRECTION" = "OUTGOING" ] && [ -f "$XCON_ID_FILE" ];
	then
		touch "$XCON_CF_FILE"
	fi

	if [ "$DIRECTION" = "INCOMING" ] && [ -f "$XCON_ID_FILE" ];
	then
		sleep 1

		if [ -f "$ACTION_CONTROL" ] || [ ! -f "$XCON_CF_FILE" ];
		then
			if [ ! -f "$XCON_CF_FILE" ]; then echo "Reverse-Script: Call was not confirmed by script (SIP-Client?)! Aborting..."; fi
			if [ ! -f "$ACTION_CONTROL" ]; then echo "Reverse-Script: Another script already got the call! Aborting..."; fi

			$DTMFBOX $SRC_ID -hook manual
			$DTMFBOX $XCON_ID -hook manual
			$DTMFBOX $XCON_ID -hook down
		else
			echo "XCON" > "$ACTION_CONTROL"			
			echo "Reverse-Script: Confirm call (Account $ACC_ID)"
		fi

		# Remove temp files
		remove_temporary_files
	fi
fi

# On disconnect
# Remove msgbox from MusicPal display
if [ "$EVENT" = "DISCONNECT" ] && [ -f $XCON_MP_FILE ] && [ ! -z "$MUSICPAL_IP" ] && [ ! -z "$MUSICPAL_PASSWORD" ];
then
	wget -O - "http://$MUSICPAL_USERNAME:$MUSICPAL_PASSWORD@$MUSICPAL_IP/admin/cgi-bin/ipc_send?menu_collapse"
	rm "$XCON_MP_FILE"
fi
