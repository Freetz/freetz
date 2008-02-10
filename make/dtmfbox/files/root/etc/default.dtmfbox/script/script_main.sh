#!/var/tmp/sh
##################################################################################
## dtmfbox - main script
##################################################################################
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

##################################################################################
## Internal (DDI)
##################################################################################
internal() {

  read_main_cfg

  let i=1
  while [ $i -le 10 ];
  do
     TMP_ACTIVE=`eval echo "\\$DTMFBOX_ACC${i}_ACTIVE"`
     if [ "$TMP_ACTIVE" = "1" ];
     then
       TMP_DDI=`eval echo "\\$DTMFBOX_SCRIPT_ACC${i}_DDI"`
       VALIDATE_ACC=`echo "$DST_NO" | sed -e "s/\(.*\)@.*/\1/g" -e "s/^$TMP_DDI.*$/OK/g"`

       # found!!
       if [ "$VALIDATE_ACC" = "OK" ]; 
       then

         dtmfbox_cmd "$SRC_CON" "-hook up"
         export ACC_NO="$i"
         read_data

         # walkthrough submenues and simulate typing
         INT_NO=`echo "$DST_NO" | sed -e "s/\(.*\)@.*/\1/g" -e "s/$TMP_DDI\(.*\)/\1/g" -e "s/[\*]/ /g" -e "s/\([[:alnum:]]\)/ \1 /g"`
         for SUBMENUE in $INT_NO
         do
           echo "DTMF"      >  ./tmp/$SRC_CON.submenue
           echo "$TYPE"     >> ./tmp/$SRC_CON.submenue
           echo "$IN_OUT"   >> ./tmp/$SRC_CON.submenue
           echo "$SRC_CON"  >> ./tmp/$SRC_CON.submenue
           echo "$DST_CON"  >> ./tmp/$SRC_CON.submenue
           echo "$SRC_NO"   >> ./tmp/$SRC_CON.submenue
           echo "$DST_NO"   >> ./tmp/$SRC_CON.submenue
           echo "$ACC_NO"   >> ./tmp/$SRC_CON.submenue
           echo "$SUBMENUE" >> ./tmp/$SRC_CON.submenue
           EVENT=`cat "./tmp/$SRC_CON.submenue"`
           rm "./tmp/$SRC_CON.submenue" 2>/dev/null
           . "$SCRIPT_WAITEVENT" "WRITE" "$EVENT"
         done

         # start blocking events
         . "$SCRIPT_WAITEVENT" "START"

         # hook up and change to script_internal.sh     
         (dtmfbox_change_script "$SRC_CON" "$SCRIPT_INTERNAL" "none" "")&

         exit 1
       fi
     fi

     let i=i+1
  done
}

##################################################################################
## Callback & Callthrough
##################################################################################
callback_callthrough() {

  # active?
  if [ "$CBCT_ACTIVE" = "1" ];
  then

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

           . "$SCRIPT_WAITEVENT" "START"
           (dtmfbox_change_script "$SRC_CON" "$SCRIPT_INTERNAL" "none" "-hook up")&

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
#!/var/tmp/sh
. $DTMFBOX_PATH/script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

if [ "\$1" = "DISCONNECT" ]; then
  (
    sleep 5  
    NEW_CON=\`$DTMFBOX -call $CALLBACK_MSN $CALLBACK_NO -scriptfile "$SCRIPT_INTERNAL" -delimiter none\`
    SRC_CON="\$NEW_CON"
    . "$SCRIPT_WAITEVENT" "START"
    . "$SCRIPT_INTERNAL" "STARTUP" "$TYPE" "OUTGOING" "\$NEW_CON" "$DST_CON" "$CALLBACK_MSN" "$CALLBACK_NO" "$ACC_NO" "$DTMF"
    rm $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh
  ) &
fi
EOF
             # change scriptfile
             chmod +x $DTMFBOX_PATH/tmp/callback_$SRC_CON.sh             

             dtmfbox_change_script "$SRC_CON" "$DTMFBOX_PATH/tmp/callback_$SRC_CON.sh" "none" ""
             exit 1;

          fi
         fi

         break;
       fi

      done

      # restore address
      DST_NO="$OLD_NO"
  fi

  return 0
}

##################################################################################
## Answering machine
##################################################################################
answering_machine() {

 # active?
 if [ "$AM" = "1" ];
 then
    # Change to answering machine script
    dtmfbox_change_script "$SRC_CON" "$SCRIPT_AM" "poundkey"
    return 1
  fi 

  return 0
}

##################################################################################
## EVENTS (OUTGOING): DDI
##################################################################################
if [ "$IN_OUT" = "OUTGOING" ];
then
  if [ "$EVENT" = "EARLY" ]; then
    internal
  fi
fi

##################################################################################
## EVENTS (INCOMING): CBCT, AM
##################################################################################
if [ "$IN_OUT" = "INCOMING" ];
then
  if [ "$EVENT" = "CONNECT" ]; 
  then
    callback_callthrough
    if [ "$?" = "1" ]; then return 1; fi

    answering_machine
    if [ "$?" = "1" ]; then return 1; fi
  fi
fi

