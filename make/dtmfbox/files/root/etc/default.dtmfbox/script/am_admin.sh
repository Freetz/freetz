#!/var/tmp/sh
. /var/dtmfbox/script.cfg
. /var/dtmfbox/script/funcs.sh
. /var/dtmfbox/script/am_funcs.sh

EVENT="$1"
TYPE="$2"
DIRECTION="$3"
SRC_ID="$4"
DST_ID="$5"
SRC_NO="$6"
DST_NO="$7"
ACC_ID="$8"
DTMF="$9"

PLAYING="/var/dtmfbox/tmp/$SRC_ID.am_admin.playing"
if [ "$EVENT" = "SETUP" ]; then EVENT="CHOOSE"; DTMF="#"; fi

sed_no2word() {
SED_NO2WORD="/var/dtmfbox/tmp/no2word.sed"
if [ ! -f "$SED_NO2WORD" ];
then
cat << EOF > "$SED_NO2WORD"
s/30\./ dreissigste/g;
s/31\./ einunddreissigste/g;

s/20\./ zwanzigste/g;
s/21\./ einundzwanzigste/g;
s/22\./ zweiundzwanzigste/g;
s/23\./ dreiundzwanzigste/g;
s/24\./ vierundzwanzigste/g;
s/25\./ fuenfundzwanzigste/g;
s/26\./ sechsundzwanzigste/g;
s/27\./ siebenundzwanzigste/g;
s/28\./ achtundzwanzigste/g;
s/29\./ neunundzwanzigste/g;

s/10\./ zehnte/g;
s/11\./ elfte/g;
s/12\./ zwoelfte/g;
s/13\./ dreizehnte/g;
s/14\./ vierzehnte/g;
s/15\./ fuenfzehnte/g;
s/16\./ sechszehnte/g;
s/17\./ siebzehnte/g;
s/18\./ achtzehnte/g;
s/19\./ neunzehnte/g;

s/1\./ erste/g;
s/2\./ zweite/g;
s/3\./ dritte/g;
s/4\./ vierte/g;
s/5\./ fuenfte/g;
s/6\./ sechste/g;
s/7\./ siebte/g;
s/8\./ achte/g;
s/9\./ neunte/g;

s/([[:digit:]])\./ \1'ste/g;

p;
EOF
fi
}

count_message() {
	let msg=0
	for file in `find /var/dtmfbox/record/$ACC_ID/*`
	do
		let msg=msg+1
	done

	# create text
	if [ "$msg" = "0" ]; then
		 PAR1="keine neuen Nachrichten"
	else
		 if [ "$msg" = "1" ]; then
			 PAR1="eine neue Nachricht"
		 else
			 PAR1="$msg neue Nachrichten"
		 fi
	fi

	# say no. of messages
	/var/dtmfbox/script/espeak.sh "Sie haben $PAR1." "$SRC_ID"
}

play_message() {

	MSG_NO=`echo "$1" | sed 's/#//g'`
	let i=1;
	found=0;

	for file in `find /var/dtmfbox/record/$ACC_ID/*`
	do
		# search file (by no.)
		if [ "$i" = "$MSG_NO" ];
		then
			found=1
			break 1
		fi	

		let i=i+1
	done

	# Play file, say date!
	if [ "$found" = "1" ];
	then
		# convert no to words ;)
		F=`echo "$file" | sed -e 's/.*\///g'`
		DD=`echo $F | sed -e 's/......\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
		MM=`echo $F | sed -e 's/...\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
		H=`echo $F | sed -e 's/..........\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
		M=`echo $F | sed -e 's/.............\(..\).*/\1/g' -e 's/0\(.\)/\1/g'`
		if [ "$M" = "0" ]; then M=""; fi

		sed_no2word
		DD=`echo "$DD." | sed -n -f "$SED_NO2WORD"`
		MM=`echo "$MM." | sed -n -f "$SED_NO2WORD"`
		MSG_NO=`echo "$MSG_NO." | sed -n -f "$SED_NO2WORD"`

		is_ftp=`echo $file | sed -e "s/.*raw/OK/g"`
		/var/dtmfbox/script/espeak.sh "$MSG_NO Nachricht, am $DD'n $MM'n - um $H Uhr $M ." "$SRC_ID"

		# Load account specific settings
		load_am_settings "$ACC_ID"

		# .. and play!
		if [ "$is_ftp" = "OK" ];
		then
			get_locktempdir
			PLAYFIFO="$LOCKTEMPDIR/$SRC_ID.am_admin_play"
			file=`echo $file | sed "s/.*\///g`

			$MKFIFO "$PLAYFIFO" 2>/dev/null
			wget -q -O - "ftp://$AM_FTP_USERNAME:$AM_FTP_PASSWORD@$AM_FTP_SERVER:$AM_FTP_PORT/$AM_FTP_PATH/$file" > "$PLAYFIFO" &
			$DTMFBOX $SRC_ID -play "$PLAYFIFO" hz=8000 mode=stream>/dev/null
		else
			$DTMFBOX $SRC_ID -play "$file" >/dev/null
		fi
	fi

	rm "$PLAYING"
}

play_stop() {
	if [ -f "$PLAYING" ]; then
		PID=`cat "$PLAYING"`
		kill -9 $PID
		rm "$PLAYING"
	fi
}

if [ "$EVENT" = "START" ]; then
	$DTMFBOX $SRC_ID -stop menu
	count_message &
	$DTMFBOX $SRC_ID -goto "menu:am"
	exit 0
fi

if [ "$EVENT" = "END" ]; then
	$DTMFBOX $SRC_ID -stop menu
	play_stop
	$DTMFBOX $SRC_ID -goto "menu:main"
	exit 0
fi

if [ "$EVENT" = "CHOOSE" ] && [ "$DTMF" != "#" ]; then
	play_stop
	(play_message "$DTMF")&
	echo "$!" > "$PLAYING"
	exit 0
fi

if [ "$EVENT" = "CHOOSE" ] && [ "$DTMF" = "#" ]; then
	$DTMFBOX $SRC_ID -stop menu
	play_stop
	$DTMFBOX $SRC_ID -goto "menu:am_setup"
	exit 0
fi

if [ "$EVENT" = "DISCONNECT" ]; then
	play_stop
	exit 0
fi
