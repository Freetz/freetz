#!/var/tmp/sh
##################################################################################
## dtmfbox - dtmf commands
##################################################################################
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

TEMP_PINFILE="./tmp/$SRC_CON.dtmfpin"

menue_ansage() {
  display_text "DTMF-Befehle" &
  say_or_beep "`SPEECH_INTERNAL_2`" &
}

##################################################################################
## pincode check
##################################################################################
dtmf_commands_pincheck() {

 if [ "$DTMFBOX_SCRIPT_PINCODE" != "" ]; 
 then

   # with pin:
   if [ "$DTMF" = "$DTMFBOX_SCRIPT_PINCODE" ]; 
   then

      # save pincode to file
      echo "$DTMFBOX_SCRIPT_PINCODE" > "$TEMP_PINFILE"
      say_or_beep "Pin akzeptiert."
      DTMF=""
      return 0;
   fi
 else
   # without pin:
   echo -n "$DTMFBOX_SCRIPT_PINCODE" > "$TEMP_PINFILE"
 fi
}

##################################################################################
## execute userdefined dtmf commands (1# - 50#)
##################################################################################
dtmf_commands() {

   # readin pincode
   if [ -f "$TEMP_PINFILE" ]; then GOTPIN=`cat "$TEMP_PINFILE"`; else GOTPIN=""; fi

   # check pin (internal only!)
   if [ "$GOTPIN" = "$DTMFBOX_SCRIPT_PINCODE" ];
   then
     DTMF=`echo "$DTMF" | sed 's/[#*]//g'`
     # execute command
     USERCMD="`eval echo \\$DTMFBOX_SCRIPT_CMD_${DTMF}`"
     if [ "$USERCMD" != "" ];
     then
        # say (status)
        display_text "Befehl $DTMF" &
        say_or_beep "Befehl $DTMF." 
        eval $USERCMD
     else
        display_text "Befehl $DTMF nicht hinterlegt" "SCROLL" &
        say_or_beep "Befehl $DTMF nicht hinterlegt." &
     fi

   # no pin (internal only)!
   else
     say_or_beep "Bitte Pin eingeben." "1" &
   fi   
}

#########################################
# STARTUP
#########################################
if [ "$EVENT" = "STARTUP" ];
then 
  rm "$TEMP_PINFILE" 2>/dev/null
  menue_ansage
fi


##################################################################################
## LOOP
##################################################################################
while [ "1" = "1" ];
do    

  #########################################
  # Wait for delimiter # or * 
  #########################################
  . "$SCRIPT_WAITEVENT" "GETMORE" "*" "#"
  
  #########################################
  # DTMF
  #########################################
  if [ "$EVENT" = "DTMF" ];
  then
     # nothing entered?
     if [ "$DTMF" = "#" ]; then
       menue_ansage
     fi

     # back to script_admin.sh (*)?
     #
     if [ "$DTMF" = "*" ];
     then     
       dtmfbox_change_script "$SRC_CON" "$SCRIPT_INTERNAL" "none"
       break;
     fi

     DTMF=`echo "$DTMF" | sed 's/\([[:alnum:]]\{0,\}\).*/\1/g'`
     if [ "$DTMF" != "" ];
     then

       # Extra pincheck for DTMF-commands (outgoing/internal only!)
       #
       dtmf_commands_pincheck 

       # Run userdefined DTMF-commands (1# - 50#)
       #
       if [ "$DTMF" != "" ];
       then
         let dtmf="$DTMF"
         if [ ! $dtmf -le 0 ] && [ ! $dtmf -ge 51 ];
         then        
           dtmf_commands 
         fi
       fi
     fi
  fi

  #########################################
  # DISCONNECT
  #########################################
  if [ "$EVENT" = "DISCONNECT" ] || [ "$EVENT" = "" ];
  then
    disconnect
    exit
  fi

done;
