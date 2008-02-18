#!/var/tmp/sh
##################################################################################
## dtmfbox - waitevent script
##################################################################################

TEMP_EVENTPID="./tmp/$SRC_CON.waitevent-pid"
TEMP_EVENTFIFO1="/var/tmp/$SRC_CON.waitevent-1"
TEMP_EVENTFIFO2="/var/tmp/$SRC_CON.waitevent-2"
TEMP_EVENTFILE="./tmp/$SRC_CON.waitevent-file"

##################################################################################
## argument parser
##################################################################################
parse() {
  EVENT="$1"
  if [ "$EVENT" = "" ]; then return 0; fi
  TYPE="$2"
  IN_OUT="$3"
  SRC_CON="$4"
  DST_CON="$5"
  SRC_NO="$6"
  DST_NO="$7"
  if [ "$ACC_NO" = "" ]; then ACC_NO="$8"; fi
  DTMF="$9"
  if [ "$DTMF" = "+" ]; then DTMF="*"; fi
}

##################################################################################
## stop/continue/kill process
##################################################################################
process_control() {  

   if [ -f "$TEMP_EVENTPID" ]; then
     export PID=`cat "$TEMP_EVENTPID"`
     kill -$1 $PID 2>/dev/null
   fi
}

##################################################################################
## $1=START - start waitevent block
##################################################################################
if [ "$1" = "START" ]; 
then 

  # Make 2 fifos and 1 file.
  # One is for writing (dtmfbox x -waitevent), the other one for reading (head -n).
  # The file is for buffering 
  $MKFIFO "$TEMP_EVENTFIFO1" 
  $MKFIFO "$TEMP_EVENTFIFO2"

  (
    # redirect dtmfbox events to fifo
    $DTMFBOX $SRC_CON -waitevent mode=endless > "$TEMP_EVENTFIFO1" &

    # tee both fifos !
    $TEE -a "$TEMP_EVENTFILE" < "$TEMP_EVENTFIFO1" > "$TEMP_EVENTFIFO2"
  )&

  echo "$!" > "$TEMP_EVENTPID"  
  export PIDS=""

 
  # PAUSE PIPE PROCESSES!
  process_control "STOP"

fi

##################################################################################
## $1=GET - get next event from queue
##################################################################################
if [ "$1" = "GET" ]; 
then 

  # wait for an event and parse it (always 9 lines)!
  if [ -f "$TEMP_EVENTPID" ] && [ -p "$TEMP_EVENTFIFO1" ] && [ -p "$TEMP_EVENTFIFO2" ];
  then
      
      # PAUSE PIPE PROCESSES!
      process_control "STOP"

      if [ -f "$TEMP_EVENTFILE" ];
      then
        WAITING_EVENTS=`$HEAD -n 1 "$TEMP_EVENTFILE" 2>/dev/null`
      else
        WAITING_EVENTS=""
      fi

      if [ "$WAITING_EVENTS" = "" ];
      then
        process_control "CONT"
        LINES=`$HEAD -n 9 "$TEMP_EVENTFIFO2"`
        process_control "STOP"
      fi

      # FETCH COMMAND FROM FILE
      let LINES_CNT=`cat "$TEMP_EVENTFILE" | grep -c ".*"`
      LINES=`$HEAD -n 9 "$TEMP_EVENTFILE"`  
      let LINES_LEFT=LINES_CNT-9
      cat "$TEMP_EVENTFILE" | $TAIL -n $LINES_LEFT > "$TEMP_EVENTFILE.2"
      cp "$TEMP_EVENTFILE.2" "$TEMP_EVENTFILE"
      rm "$TEMP_EVENTFILE.2"

      # Parse event to variables
      parse `echo "$LINES" | sed "s/^\*$/+/g"`

      # RESUME PIPE PROCESSES!
      process_control "CONT"

  else
    EVENT=""
  fi
fi

##################################################################################
## $1=GETMORE - get next event from queue (join dtmf-sequence until delimiter)
##################################################################################
if [ "$1" = "GETMORE" ]; 
then

  #########################################
  # Wait for delimiter $2, $3 and $4
  #########################################
  DTMF_JOINED=""
  DELIMITER_FOUND="0"
  while [ "$DELIMITER_FOUND" = "0" ];
  do 
    . "$SCRIPT_WAITEVENT" "GET"

    if [ "$EVENT" = "DTMF" ] && [ "$DTMF" = "$2" ]; then 
      DTMF_JOINED="$DTMF_JOINED$DTMF"
      DELIMITER_FOUND="1"
    fi
    if [ "$EVENT" = "DTMF" ] && [ "$DTMF" = "$3" ]; then 
      DTMF_JOINED="$DTMF_JOINED$DTMF"
      DELIMITER_FOUND="1"
    fi
    if [ "$EVENT" = "DTMF" ] && [ "$DTMF" = "$4" ]; then 
      DTMF_JOINED="$DTMF_JOINED$DTMF"
      DELIMITER_FOUND="1"
    fi

    if [ "$EVENT" = "DISCONNECT" ]; then
      DELIMITER_FOUND="1"
    fi

    if [ "$DELIMITER_FOUND" = "0" ]; then
      DTMF_JOINED="$DTMF_JOINED$DTMF"
    fi
  done
  DTMF="$DTMF_JOINED"

fi

##################################################################################
## $1=WRITE write an event to the temp file (for submenues in script_main.sh)
##################################################################################
if [ "$1" = "WRITE" ];
then
  process_control "STOP"
  echo "$2" >> "$TEMP_EVENTFILE"
  process_control "CONT"
fi

##################################################################################
## $1=STOP stop waitevent block
##################################################################################
if [ "$1" = "STOP" ]; 
then 

  if [ -f "$TEMP_EVENTPID" ];
  then
    process_control "CONT"

    # redirect events to scriptfile again
    dtmfbox_cmd "$SRC_CON" "-stop waitevent"

    # stop waitevent (forced)
    process_control "TERM"
 
    # remove temporary pipes/files
    rm "$TEMP_EVENTFIFO1"  2>/dev/null
    rm "$TEMP_EVENTFIFO2"  2>/dev/null
    rm "$TEMP_EVENTFILE"   2>/dev/null
    rm "$TEMP_EVENTFILE.2" 2>/dev/null
    rm "$TEMP_EVENTPID"    2>/dev/null
  fi

fi
