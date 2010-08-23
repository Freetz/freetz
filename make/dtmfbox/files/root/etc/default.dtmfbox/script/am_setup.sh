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

if [ "$EVENT" = "ON_OFF" ];
then
  $DTMFBOX $SRC_ID -stop menu
  load_am_settings "$ACC_ID"

  TEXT="Der Anrufbeantworter ist"
  if [ "$AM_ACTIVE" = "1" ]; then
	TEXT="$TEXT aktiv. Druecken Sie 1, um den Anrufbeantworter zu deaktivieren."
  else
	TEXT="$TEXT nicht aktiv. Druecken Sie 1, um den Anrufbeantworter zu aktivieren."
  fi

  $DTMFBOX $SRC_ID -goto "menu:am_on_off"
  $DTMFBOX $SRC_ID -speak "$TEXT"
  exit 1
fi

if [ "$EVENT" = "DO_ON_OFF" ];
then
  IS_GLOBAL="`cat /var/dtmfbox/script.cfg | sed -e 's/#.*//g' | grep \"GLOBAL_AM_ACTIVE=\"`"
  IS_ACCOUNT="`cat /var/dtmfbox/script.cfg | sed -e 's/#.*//g' | grep \"ACC${ACC_ID}_AM_ACTIVE=\"`"

  if [ ! -z "$IS_GLOBAL" ]; then CFG_KEY="GLOBAL_AM_ACTIVE"; fi
  if [ ! -z "$IS_ACCOUNT" ]; then CFG_KEY="ACC${ACC_ID}_AM_ACTIVE"; fi

  get_cfg_value /var/dtmfbox/script.cfg "" "$CFG_KEY"

  CFG_VALUE="`echo $CFG_VALUE | sed -e 's/#.*//' -e 's/\"//g'`"
  if [ ! -z "$CFG_VALUE" ];
  then
	if [ "$CFG_VALUE" = "0" ]; then
		NEW_CFG_VALUE="1";
		TEXT="Der Anrufbeantworter wird aktiviert."
	else
		NEW_CFG_VALUE="0";
		TEXT="Der Anrufbeantworter wird deaktiviert."
	fi

	$DTMFBOX $SRC_ID -stop menu
	/var/dtmfbox/script/espeak.sh "$TEXT" "$SRC_ID" &
	set_cfg_value /var/dtmfbox/script.cfg "" "$CFG_KEY" "\"$NEW_CFG_VALUE\"" 
	$DTMFBOX $SRC_ID -goto "menu:am_setup"
  fi

  exit 1
fi

if [ "$EVENT" = "DELETE_ALL" ];
then
  $DTMFBOX $SRC_ID -stop menu
  load_am_settings "$ACC_ID"
  get_locktempdir
  
  echo "USER $AM_FTP_USERNAME" >  $LOCKTEMPDIR/nc_ftp_cmd
  echo "PASS $AM_FTP_PASSWORD" >> $LOCKTEMPDIR/nc_ftp_cmd
  echo "CWD $AM_FTP_PATH"  >> $LOCKTEMPDIR/nc_ftp_cmd

  chmod +x $LOCKTEMPDIR/nc_ftp_cmd
		
  FTP_FOUND="0"
  for file in `find /var/dtmfbox/record/$ACC_ID/*`
  do
	# delete remote:
	filename=`echo $file | sed 's/^.*\/\(.*\..*\)$/\1/g'`
	IS_FTP=`echo $filename | sed 's/^.*\.raw$/FTP/g'`
	if [ "$IS_FTP" ]; then
	  FTP_FOUND="1";
	  echo "DELE $filename" >> $LOCKTEMPDIR/nc_ftp_cmd
	fi

	# delete local:
	rm "$file";
  done

  if [ "$FTP_FOUND" = "1" ]; then
	echo "QUIT"  >> $LOCKTEMPDIR/nc_ftp_cmd
	cat $LOCKTEMPDIR/nc_ftp_cmd | $NC $FTP_SERVER:$FTP_PORT;
  fi
  rm $LOCKTEMPDIR/dtmfbox_delete_ftp.sh 2>/dev/null

  /var/dtmfbox/script/espeak.sh "Alle Aufnahmen wurden geloescht." "$SRC_ID"
  $DTMFBOX $SRC_ID -goto "menu:am_setup"
  exit 1
fi


