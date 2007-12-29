#!/bin/sh
# ------------------------------------------------------------------------
# dtmfbox - userdefined dtmf-commands
# ------------------------------------------------------------------------
. ./script/script_funcs.sh
if [ "$?" = "1" ]; then exit 1; fi

# ------------------------------------------------------------------------
# Extra pincode check for DTMF-commands (outgoing & internal only!) (Pincode#)
# ------------------------------------------------------------------------
dtmf_commands_pincheck() {

 if [ "$DTMFBOX_SCRIPT_PINCODE" != "" ]; 
 then

   # with pin:
   if [ "$DTMF" = "$DTMFBOX_SCRIPT_PINCODE" ]; 
   then

      # save pincode to file
      echo "$DTMFBOX_SCRIPT_PINCODE" > "$PINFILE_DTMF"
      say_or_beep "Pin akzeptiert."
      exit 1;

   fi
 else
   # without pin:
   echo "$DTMFBOX_SCRIPT_PINCODE" > "$PINFILE_DTMF"
 fi
}

# ------------------------------------------------------------------------
# Userdefined DTMF-commands (1# - 50#)
# ------------------------------------------------------------------------
dtmf_commands() {

  let i=1

  while [ $i -le 50 ];
  do

    USERDTMF="`eval echo ${i}`"

    if [ "$DTMF" = "$USERDTMF" ]; 
    then        

      # readin pincode
      if [ -f "$PINFILE_DTMF" ]; then GOTPIN=`cat "$PINFILE_DTMF"`; else GOTPIN=""; fi

      # check pin (internal only!)
      if [ "$GOTPIN" = "$DTMFBOX_SCRIPT_PINCODE" ];
      then

        # say (status)
        say_or_beep "Befehl $USERDTMF"

        # execute command
        USERCMD="`eval echo \\$DTMFBOX_SCRIPT_CMD_${i}`"
        eval $USERCMD

      # no pin (internal only)!
      else
        say_or_beep "Bitte Pin eingeben." "1"
      fi

      exit 1;
    fi

    let i=$i+1

  done 
}

# --------------------------------------------------------------------------------
# execute user-script, if exist 
# --------------------------------------------------------------------------------
if [ -f "$USERSCRIPT" ]; 
then
  SCRIPT="DTMF"
  . $USERSCRIPT
  if [ "$?" = "1" ]; then exit 1; fi
fi

# --------------------------------------------------------------------------------
# STARTUP-EVENT (called by script_admin.sh when scriptfile changes, not by dtmfbox)
# --------------------------------------------------------------------------------
if [ "$EVENT" = "STARTUP" ];
then 
  say_or_beep "DTMF Befehle. 1 bis 50."
fi

# --------------------------------------------------------------------------------
# DTMF-EVENT
# --------------------------------------------------------------------------------
if [ "$EVENT" = "DTMF" ];
then

   # nothing entered?
   if [ "$DTMF" = "" ]; then
     $0 STARTUP $TYPE $IN_OUT $SRC_CON $DST_CON "$SRC_NO" "$DST_NO" "$ACC_NO" "$DTMF" 
   fi

   # back to script_admin.sh (*#)?
   #
   if [ "$DTMF" = "*" ];
   then     
     redirect "$ADMINSCRIPT" "zurueck"
     exit 1
   fi

   # Extra pincheck for DTMF-commands (outgoing/internal only!)
   #
   dtmf_commands_pincheck_before
   if [ "$?" = "0" ]; then dtmf_commands_pincheck; fi
   dtmf_commands_pincheck_after


   # Run userdefined DTMF-commands (1# - 50#)
   #
   dtmf_commands_before
   if [ "$?" = "0" ]; then dtmf_commands; fi
   dtmf_commands_after

fi

