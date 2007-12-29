#!/bin/sh
# --------------------------------------------------------------------------------
# dtmfbox - main script
# --------------------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# --------------------------------------------------------------------------------
# Create record filename ($DATE___$SRC_NO___$DST_NO.wav) !! 
# --------------------------------------------------------------------------------
generate_rec_filename() {

  RECFILE_NAME="`echo $SRC_NO-$DST_NO | sed 's/@.*//g' | sed 's/\./_/g' | sed 's/\*//g' | sed 's/#//g'`"
  DATE="`date +'%y-%m-%d'`"
  DATETIME="`date +'%y-%m-%d--%H-%M-%S'`"
  RECFILE_UNIQUE="`echo $DTMFBOX_PATH/record/$ACC_NO/$DATETIME---$RECFILE_NAME.wav`"
  RECFILE_UNIQUE_FTP="`echo $DATETIME---$RECFILE_NAME.raw`"
  RECFILE="`echo $DTMFBOX_PATH/record/$ACC_NO/$DATE---$RECFILE_NAME-$SRC_CON.wav`"
  DATETEXT="`date +'am %d.%m.%y, um %H:%M Uhr.'`"
}

# --------------------------------------------------------------------------------
# create email body and subject
# --------------------------------------------------------------------------------
create_mail() {

MAIL_SUBJECT="dtmfbox - Anrufbeantworter - von $DST_NO an $SRC_NO"

cat << EOF > $DTMFBOX_PATH/tmp/inline_$SRC_CON.txt
----------------------------------------------------------------
 dtmfbox - Anrufbeantworter
----------------------------------------------------------------
 Anruf ($TYPE)
 von $DST_NO für $SRC_NO
 $DATETEXT
----------------------------------------------------------------
EOF
}

# --------------------------------------------------------------------------------
# mailer-function
# --------------------------------------------------------------------------------
mailer() {

  if [ "$MAIL_ACTIVE" = "1" ]; 
  then

    if [ -f "$RECFILE" ] && [ "$MAIL_TO" != "" ]; 
    then   

      # create mail body & subject
      #       
      create_mail

      # send mail
      #
      /sbin/mailer -s "$MAIL_SUBJECT" \
             -f "$MAIL_FROM" \
             -t "$MAIL_TO" \
             -m "$MAIL_SERVER" \
             -a "$MAIL_USER" \
             -w "$MAIL_PASS" \
             -d "$RECFILE" \
             -i "$DTMFBOX_PATH/tmp/inline_$SRC_CON.txt"

      # remove mail-body
      #
      rm "$DTMFBOX_PATH/tmp/inline_$SRC_CON.txt"

      # delete recording?
      #
      if [ "$MAIL_DELETE" = "1" ];
      then
        rm "$RECFILE"
      fi

    fi
  fi

}

# --------------------------------------------------------------------------------
# check, if the configured timespan is valid
# --------------------------------------------------------------------------------
check_time() {

   let H_START="`echo $ON_AT | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
   let M_START="`echo $ON_AT | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"
   let H_END="`echo $OFF_AT | sed 's/:.*//g' | sed -e 's/^0\(.*\)/\1/g'`"
   let M_END="`echo $OFF_AT | sed 's/.*://g' | sed -e 's/^0\(.*\)/\1/g'`"

   if [ "$M_END" = "0" ]; then
    let M_END=60
   fi
   if [ "$H_END" = "0" ]; then
    let H_END=24
   fi

   let H="`date +'%H' | sed -e 's/^0\(.*\)/\1/g'`"
   let M="`date +'%M' | sed -e 's/^0\(.*\)/\1/g'`"

   ok=0

   if [ $H_START -le $H ] && [ $H -le $H_END ];
   then
     if [ "$H_START" = "$H" ] || [ "$H_END" = "$H" ]; 
     then
       if [ $M_START -le $M ] && [ $M -le $M_END ]; 
       then
         ok=1
       fi
     else
       ok=1
     fi
   fi

   return $ok
}

# --------------------------------------------------------------------------------
# kill idle script
# --------------------------------------------------------------------------------
kill_idle() {

    # 
    # Read PID file from idle-script and kill it!
    # 
    if [ -f "$DTMFBOX_PATH/tmp/script_am_$SRC_CON.pid" ];
    then
      PID=`cat "$DTMFBOX_PATH/tmp/script_am_$SRC_CON.pid"`

      for pid in $PID
      do
        if [ "$pid" != "0" ]; then kill "$pid"; fi
      done

      # remove pid file
      rm $DTMFBOX_PATH/tmp/script_am_$SRC_CON.pid 2>/dev/null
      
    else
      return 0
    fi

    return 1
}

# --------------------------------------------------------------------------------
# OUTGOING/DTMF: change scriptfile to script_admin.sh (administration)
# --------------------------------------------------------------------------------
internal_dial() {

     DST_NO=`echo "$DST_NO" | sed 's/\*/-/g'`
     DTMFBOX_CAPI_DDI_PREFIX=`echo "$DTMFBOX_CAPI_DDI_PREFIX" | sed 's/\*/-/g'`

     DST_NO_OK=`echo "$DST_NO" | sed -e "s/^$DTMFBOX_CAPI_DDI_PREFIX...[-#].*$/OK/g"`

     if [ "$DST_NO_OK" = "OK" ] && [ ! -f "$CURACCOUNT" ];
     then

     remove_status_files;
     kill_dead_scripts "0";
    
     # check dtmf in destination number and change the scriptfile
     let i=1
     while [ $i -le 10 ];
     do
 
       VALIDATE_ACC1=`echo "$DST_NO" | sed "s/$DTMFBOX_CAPI_DDI_PREFIX\0\0${i}[-#].*/OK/g"`
       VALIDATE_ACC2=`echo "$DST_NO" | sed "s/$DTMFBOX_CAPI_DDI_PREFIX\0${i}[-#].*/OK/g"`

       if [ "$VALIDATE_ACC1" = "OK" ] || [ "$VALIDATE_ACC2" = "OK" ]; 
       then

         # hook up
         $DTMFBOX $SRC_CON -hook up 

         # check if account is active and acc_no is given!
         ACC_ACTIVE=`eval echo \\$DTMFBOX_ACC${i}_ACTIVE`        

         if [ "$ACC_ACTIVE" = "0" ]; # || [ "$ACC_NO" = "-1" ];
         then
            say_or_beep "Account ist nicht aktiv." "1"
            $DTMFBOX $SRC_CON -hook down
            exit 1
         fi

         # save choosen account no
         echo "${i}" > "$CURACCOUNT"

         # change scriptfile (script_admin.sh)
         redirect "$ADMINSCRIPT"

         # goto submenue?
         SUBMENUES=`echo "$DST_NO" | sed 's/-/ /g' | sed 's/#/ /g'`

         if [ "$SUBMENUES" != "" ];
         then

           # count submenues
           let submenue_cnt=0
           for SUBMENUE in $SUBMENUES
           do
             let submenue_cnt=submenue_cnt+1
           done

           for SUBMENUE in $SUBMENUES
           do 

              # get current scriptfile
              export CHANGE_SCRIPT=`cat $CURSCRIPT 2>/dev/null`

              # enable say_or_beep on last menue
              let submenue_cnt=submenue_cnt-1

              # echo " >> SUBMENU: \"$SUBMENUE\" - CURSCRIPT: $CURSCRIPT - $GOT_USB"

              # simulate typing dtmf signals              
              if [ "$CHANGE_SCRIPT" != "" ];
              then
                if [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.lock" ];
                then
                  while [ -f "$DTMFBOX_PATH/tmp/$SRC_CON.getlock" ]; do sleep 1; done;
                  echo "$SUBMENUE" >> "$DTMFBOX_PATH/tmp/$SRC_CON.dtmf"
                else
                  $DTMFBOX $SRC_CON -timer 1 "SUBMENUE_TIMER \"$CURSCRIPT\" \"$SUBMENUE\" \"$DTMFBOX\" \"$TIMERSCRIPT\" \"$BATCHMODE\"" mode=msec -scriptfile "$TIMERSCRIPT"
  				  sleep 1
                fi
              fi
           done
         fi

         export BATCHMODE=0
         exit 1;
       fi
       let i=i+1
		
     done
   fi

   export BATCHMODE=0
}

# --------------------------------------------------------------------------------
# INCOMING/CONNECT: callback/callthrough
# --------------------------------------------------------------------------------
callback_callthrough() {

    # extract no from address 
    if [ "$TYPE" = "VOIP" ];
    then
       OLD_NO="$DST_NO"
       DST_NO=`echo $DST_NO | sed 's/\(.*\)@.*/\1/g'`
    else
       OLD_NO="$DST_NO"
       DST_NO="$DST_NO"
    fi

    # walkthrough trigger-numbers
    for CBCT_NO in $CBCT_TRIGGERNO
    do

      # Strip numbers (Trigger-No/Callback-No/Callback-MSN)
      #
      TRIGGER_NUMBERS=`echo $CBCT_NO | sed 's/\// /g'`
      let i=0;
      TRIGGER_NO=""
      CALLBACK_NO=""
      CALLBACK_MSN=""
      for TRIGGER_NUMBER in $TRIGGER_NUMBERS; 
      do
        if [ "$i" = "0" ]; then TRIGGER_NO="$TRIGGER_NUMBER"; fi
        if [ "$i" = "1" ]; then CALLBACK_NO="$TRIGGER_NUMBER"; fi
        if [ "$i" = "2" ]; then CALLBACK_MSN="$TRIGGER_NUMBER"; fi            
        let i=i+1;
      done           
      if [ "$CALLBACK_NO" = "" ]; then CALLBACK_NO="$DST_NO"; fi
      if [ "$CALLBACK_MSN" = "" ]; then CALLBACK_MSN="$ACC_MSN"; fi

      # check for valid trigger number
      VALID_CBCT=`echo $DST_NO | sed s/$TRIGGER_NO/OK/g`

      # number found?
      #
      if [ "$VALID_CBCT" = "OK" ]; 
      then

        # callthrough: change scriptfile and hook up...
        # ------------------------------------------------------------------------------
        if [ "$CBCT_TYPE" = "ct" ]; 
        then

           # save current MSN 
           echo "$ACC_MSN" > "$CURCALLBACK"

           # change scriptfile for SRC_CON
           redirect "$CBCTSCRIPT"

           # hook up
           $DTMFBOX $SRC_CON -hook up

           # cbct startup         
           $CBCTSCRIPT STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF"

           # exit this script...
           exit 1;
         fi

         # callback: call on disconnect
         # ------------------------------------------------------------------------------
         if [ "$CBCT_TYPE" = "cb" ]; 
         then

         # replace callback no?
         CALLBACK_NO=`echo $DST_NO | sed s/$TRIGGER_NO/$CALLBACK_NO/g`
         if [ "$CALLBACK_NO" != "" ]; then 

# create callback script
cat << EOF > $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh
#!/bin/sh
if [ "\$1" = "DISCONNECT" ]; then
  sleep 5  
  echo "$CBCTSCRIPT" > "$CURSCRIPT"
  NEW_CON=\`$DTMFBOX -call $CALLBACK_MSN $CALLBACK_NO -scriptfile "$CBCTSCRIPT" -delimiter poundkey\`
  CURCALLBACK="$DTMFBOX_PATH/tmp/current_cb_account_\$NEW_CON.tmp"
  CURACCOUNT="$DTMFBOX_PATH/tmp/current_account_\$NEW_CON.tmp"
  echo "$CALLBACK_MSN" > "\$CURCALLBACK"
  echo "$ACC_NO" > "\$CURACCOUNT"
  rm $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh
fi
EOF
             # change scriptfile
             chmod +x $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh             
             redirect "$DTMFBOX_PATH/tmp/callback_$SRC_CON.sh"
             exit 1;

          fi
         fi

         break;
       fi

      done

      # restore address
      DST_NO="$OLD_NO"
}

# --------------------------------------------------------------------------------
# INCOMING/CONNECT: answering machine 
# --------------------------------------------------------------------------------
answering_machine() {

 # Answering machine on?
 if [ "$AM" = "1" ];
 then

    generate_rec_filename

    # redirect unknown callers only?
    if [ "$UNKNOWN_ONLY" = "1" ];
    then
      . "$SEDSCRIPT"
      sed_tolower

      TMP_DST=`echo "$DST_NO" | sed -e 's/@.*//g' | sed -n -f "$SED_TOLOWER" | sed -e 's/anonymous/unknown/g' -e 's/anonym/unknown/g'`      
      if [ "$TMP_DST" = "" ]; then TMP_DST="unknown"; fi

      # not unknown? then exit!
      if [ "$TMP_DST" != "unknown" ]; then exit 1; fi
    fi

    # timespan valid...?
    check_time; val=$?
    if [ "$val" = "0" ]; then exit 1; fi

    # Start idle script (ringing)
    . $DTMFBOX_PATH/script/script_am.sh  
    val=$?	
    if [ "$val" != "1" ]; then exit 1; fi

  fi

}


# --------------------------------------------------------------------------------
# INCOMING/DTMF: ask for pincode and change to scriptfile script_admin.sh
# --------------------------------------------------------------------------------
administration() {

 # Pincode ok?
 if [ "$DTMF" = "$AM_PIN" ] && [ "$AM_PIN" != "" ];
 then

   # Stop idle-script
   kill_idle

   generate_rec_filename
	     
   # Stop record and change the scriptfile (to script_admin.sh)
   $DTMFBOX $SRC_CON -stop record
   redirect "$ADMINSCRIPT"

   # remove recording 
   rm "$RECFILE" 2>/dev/null

   # run admin "custom" script event "STARTUP" (say no. of messages or beep)
   $ADMINSCRIPT STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF"
 fi

}

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="MAIN"
  . $USERSCRIPT
  if [ "$?" = "1" ]; then exit 1; fi
fi


# --------------------------------------------------------------------------------
#
#   OUTGOING (INTERNAL/CALL)
#
# --------------------------------------------------------------------------------
if [ "$IN_OUT" = "OUTGOING" ];
then

	# --------------------------------------------------------------------------------
	# DDI-EVENT (INTERNAL *#001# - *#010#)
	# --------------------------------------------------------------------------------
	if [ "$EVENT" = "DDI" ]; 
	then
       internal_dial_before
       if [ "$?" = "0" ]; then internal_dial; fi
       internal_dial_after
    fi

    # exit!
	exit 1;

fi

# --------------------------------------------------------------------------------
#
#   INCOMING (EXTERNAL)
#
# --------------------------------------------------------------------------------
if [ "$IN_OUT" = "INCOMING" ]; 
then

    search4msn

	# --------------------------------------------------------------------------------
    # CONNECT-EVENT (callback/callthrough)
	# --------------------------------------------------------------------------------
	if [ "$EVENT" = "CONNECT" ] && [ "$CBCT_ACTIVE" = "1" ]; 
	then
      # callback / callthrough
      callback_callthrough_before
      if [ "$?" = "0" ]; then callback_callthrough; fi             
      callback_callthrough_after
    fi

	# --------------------------------------------------------------------------------
	# CONNECT-EVENT (answering machine)
	# --------------------------------------------------------------------------------
	if [ "$EVENT" = "CONNECT" ]; 
	then
      # answering machine
      answering_machine_before
      if [ "$?" = "0" ]; then answering_machine; fi
      answering_machine_after
	fi
		
	# --------------------------------------------------------------------------------
	# CONFIRMED-EVENT
	# --------------------------------------------------------------------------------
	if [ "$EVENT" = "CONFIRMED" ];
	then
	   # Stop idle-script when a client confirmed
	   SRC_CON=$DST_CON
	   kill_idle
	fi	
	
	# --------------------------------------------------------------------------------
	# DTMF-EVENT
	# --------------------------------------------------------------------------------
	if [ "$EVENT" = "DTMF" ]; 
	then
       # administration (ask for pin)
       administration_before
       if [ "$?" = "0" ]; then administration; fi       
       administration_after
	fi
		
    # --------------------------------------------------------------------------------
    # DISCONNECT-EVENT
    # --------------------------------------------------------------------------------
    if [ "$EVENT" = "DISCONNECT" ]; 
    then	    

      if [ "$AM" = "1" ];
      then
     
        generate_rec_filename

        # send email
        mailer_before
        RETVAL="$?"

        if [ "$RECORD" != "OFF" ]; 
        then	

   	      # Stop idle-script
          kill_idle
	  
          if [ -f "$RECFILE" ]; then
		
            # Make recordings "unique" (add time)
            mv "$RECFILE" "$RECFILE_UNIQUE"
            RECFILE="$RECFILE_UNIQUE"
	
            # Mailer...
            #
            if [ "$RETVAL" = "0" ]; then mailer; fi

          fi
        fi

        mailer_after

       fi

    fi

    # exit!
    exit 1;

fi

