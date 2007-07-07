#!/bin/sh
# --------------------------------------------------------------------------------------------------------------------
# dtmfbox v0.3.9 - main script (c) 2007 Marco Zissen
#
# This program is free ! Use it at your own risk ! The author does not give any warranty !
# --------------------------------------------------------------------------------------------------------------------

. ./script/script_funcs.sh

# --------------------------------------------------------------------------------
# Record-File ($DATE___$SRC_NO___$DST_NO.wav) !! Attention: without whitespaces !!
# --------------------------------------------------------------------------------
RECFILE="`echo $SRC_NO-$DST_NO | sed 's/@.*//g' | sed 's/\./_/g' | sed 's/\*//g' | sed 's/#//g'`"
DATE="`date +'%y-%m-%d'`"
DATETIME="`date +'%y-%m-%d--%H-%M-%S'`"
RECFILE_UNIQUE="`echo $DTMFBOX_PATH/record/$SRC_NO/$DATETIME---$RECFILE.wav`"
RECFILE="`echo $DTMFBOX_PATH/record/$SRC_NO/$DATE---$RECFILE-$SRC_CON.wav`"
DATETEXT="`date +'am %d.%m.%y, um %H:%M Uhr.'`"

# --------------------------------------------------------------------------------
# OUTGOING/DTMF: change scriptfile to script_admin.sh (administration)
# --------------------------------------------------------------------------------
internal_dial() {

   # hook up
   if [ "$DTMF" = "*" ];
   then
     $DTMFBOX $SRC_CON -hook up        
     exit 1;
   fi

   # check dtmf + change script
   let i=0
   while [ $i -le 9 ];
   do
           
     USERDTMF=`eval echo 10${i}`
      
     if [ "$DTMF" = "$USERDTMF" ]; then

         # check if account is active
         let id=i+1
         ACC_ACTIVE=`eval echo \\$DTMFBOX_ACC${id}_ACTIVE`
            
         if [ "$ACC_ACTIVE" = "0" ];
         then
            say_or_beep "Account ist nicht aktiv." "1"
            $DTMFBOX $SRC_CON -hook down
            exit 1
         fi

         # change scriptfile (script_admin.sh)
         $DTMFBOX $SRC_CON -scriptfile $ADMINSCRIPT

         # run admin "custom" script event "STARTUP" (say count of messages or beep)
         $ADMINSCRIPT STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$DTMF"            

         exit 1
     fi
     let i=i+1

   done
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
      if [ "$CALLBACK_NO" = "" ]; then CALLBACK_NO="$TRIGGER_NO"; fi
      if [ "$CALLBACK_MSN" = "" ]; then CALLBACK_MSN="$ACC_MSN"; fi

      # check for valid trigger number
      VALID_CALLBACK=`echo $DST_NO | sed s/$TRIGGER_NO/OK/g`

      # number found?
      #
      if [ "$VALID_CALLBACK" = "OK" ]; 
      then

        # callthrough: change scriptfile and hook up...
        # ------------------------------------------------------------------------------
        if [ "$CBCT_TYPE" = "ct" ]; 
        then

           # save current MSN 
           echo $ACC_MSN > "$MSNFILE"

           # change scriptfile for SRC_CON
           $DTMFBOX $SRC_CON -scriptfile "$ADMINSCRIPT"

           # hook up
           $DTMFBOX $SRC_CON -hook up

           # exit this script...
           exit 1;
         fi

         # callback: call on disconnect
         # ------------------------------------------------------------------------------
         if [ "$CBCT_TYPE" = "cb" ]; 
         then

# create callback script
cat << EOF > $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh
#!/bin/sh
if [ "\$1" = "DISCONNECT" ]; then
  echo $ACC_MSN > "$MSNFILE"
  sleep 1
  NEW_CON=\`$DTMFBOX -call $CALLBACK_MSN $CALLBACK_NO\`
  sleep 1
  $DTMFBOX \$NEW_CON -scriptfile "$ADMINSCRIPT" -delimiter poundkey
  rm $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh
fi
EOF
             # change scriptfile
             chmod +x $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh             
             $DTMFBOX $SRC_CON -scriptfile $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh
             exit 1;
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

    # Timespan valid...?
    check_time; val=$?

    # .. no? then do not answer
    if [ "$val" = "0" ]; then exit 1; fi
	    
    # Start idle script (ringing)
    . $DTMFBOX_PATH/script/script_idle.sh  
    val=$?
	
    if [ "$val" != 1 ]; then
      # Caller disconnected before script ends
      exit 1          
    fi

  fi
}


# --------------------------------------------------------------------------------
# INCOMING/DTMF: ask for pincode and change to scriptfile script_admin.sh
# --------------------------------------------------------------------------------
administration() {

 # Pincode ok?
 if [ "$DTMF" = "$DTMFBOX_SCRIPT_PINCODE" ];
 then
   # Stop idle-script
   kill_idle
	     
   # Stop record and change the scriptfile (to script_admin.sh)
   $DTMFBOX $SRC_CON -stop record -scriptfile $ADMINSCRIPT
   rm "$RECFILE"

   # run admin "custom" script event "STARTUP" (say no. of messages or beep)
   $ADMINSCRIPT STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$DTMF"
 fi

}

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="MAIN"

  . $USERSCRIPT

  # returned 1? exit!
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
	# DTMF-EVENT (INTERNAL *#100# - *#109#)
	# --------------------------------------------------------------------------------
	if [ "$EVENT" = "DTMF" ]; 
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

    # search for msn (set variables)
    search4msn

	# --------------------------------------------------------------------------------
    # CONNECT-EVENT (callback/callthrough)
	# --------------------------------------------------------------------------------
	if [ "$EVENT" = "CONNECT" ] && [ "$CBCT" = "1" ]; 
	then
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
	   # Stop idle-script when client confirmed
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

      # send email

      mailer_before
      RETVAL="$?"

      if [ "$RECORD" != "OFF" ]; 
      then	

	    # Stop idle-script
        kill_idle
	  
        if [ -f $RECFILE ]; then
		
          # Make recordings "unique" (add time)
          mv $RECFILE $RECFILE_UNIQUE
          RECFILE=$RECFILE_UNIQUE
	
          # Mailer...
          #
          if [ "$RETVAL" = "0" ]; then mailer; fi

        fi
      fi

    mailer_after

    fi

    # exit!
    exit 1;

fi

