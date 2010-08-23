#!/var/tmp/sh
. /var/dtmfbox/script.cfg

MODE="$1"
SRC_ID="$2"
TEXT=""

#########################
## 1 - IP-Adresse
#########################
if [ "$MODE" = "IP" ];
then
	TEXT="Ihre Ei,Pi Adresse lautet: `showdsldstat | grep '0: ip' | sed -e 's/.*ip \(.*\) peer.*/\1/g' -e 's/\./  ,,punkt,,  /g`"
fi

#########################
## 2 - Letzter Reboot
#########################
if [ "$MODE" = "LAST_REBOOT" ];
then
	IS_MIN=`uptime | sed -r 's/.*up (.*) min.*$/OK/g'`
	IS_DAY=`uptime | sed -r 's/.*up (.*) day.*$/OK/g'`
	if [ "$IS_MIN" = "OK" ] && [ "$IS_DAY" != "OK" ];
	then
		NO=`uptime | sed -r 's/.*up (.*) min.*$/\1/g'`
		FRMT=" Minuten "
	else
		if [ "$IS_DAY" = "OK" ];
		then
			NO=`uptime | sed -r 's/.*up (.*) day.*$/\1/g'`
			if [ "$NO" = "1" ]; then FRMT=" einem Tag "; NO=""; else FRMT=" Tagen "; fi
		else
			NO=`uptime | sed -r 's/.*up (.*):.*:.*/\1/g'`
			NO2=`uptime | sed -r 's/.*up .*:(.*),.*:.*/\1/g'`
			NO=`echo "$NO" | sed -r 's/0(.)/\1/g'`
			NO2=`echo "$NO2" | sed -r 's/0(.)/\1/g'`
			if [ "$NO" = "1" ]; then FRMT=" einer Stunde "; NO=""; else FRMT=" Stunden "; fi
			if [ "$NO2" = "1" ]; then FRMT2=" einer Minute "; NO2=""; else FRMT2=" Minuten "; fi
			NO="$NO $FRMT und $NO2 $FRMT2"
			FRMT=""; FRMT2=""
		fi
	fi
	TEXT="Vor $NO $FRMT war der letzte Ribuht."
fi

#########################
## 3 - Uhrzeit
#########################
if [ "$MODE" = "CURRENT_TIME" ];
then
	TEXT="Es ist: `date +\"%H Uhr %M .\"`."
fi

#########################
## OUTPUT
#########################
if [ "$TEXT" != "" ]; then
	$DTMFBOX $SRC_ID -speak "$TEXT"
fi
