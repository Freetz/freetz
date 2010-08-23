#!/var/tmp/sh

# Get a value from a [section] and key= (*.cfg file)
#  $1=file.cfg
#  $2=Section (without [])
#  $3=Key (key=)
#
#  returns: $CFG_VALUE
#
get_cfg_value() {

  FILE="$1"
  SECTION="$2"
  KEY="$3"
  CFG_VALUE=""

  let cnt=1
  let in_section=0

  if [ -z "$SECTION" ]; then
	COMMENTARY="#.*"
	SLINE_NUM=`cat "$FILE" | sed -e "s/$COMMENTARY//g" | grep -n "$KEY=" | sed -e 's/\(.*\):.*/\1/g'`
	if [ -z "$SLINE_NUM" ]; then return; fi	
	let LINE_NUM=$SLINE_NUM
	let in_section=2;
  else
	COMMENTARY="\/\/.*"
	SLINE_NUM=`cat "$FILE" | sed "s/$COMMENTARY//g" | grep -n "\[$SECTION\]" | sed -e 's/\(.*\):.*/\1/g'`
	if [ -z "$SLINE_NUM" ]; then return; fi	
	let LINE_NUM=$SLINE_NUM
	let in_section=2;
  fi

  while read line;
  do
	if [ $cnt -eq $LINE_NUM ];
	then		
		# check, if we enter the section
		if [ $in_section -eq 2 ]; then		
			if [ ! -z "`echo $line | grep \"$KEY=\"`" ];
			then 	
				CFG_VALUE="`echo "$line" | sed -e "s/$COMMENTARY//g" -e \"s/$KEY\=\(.*\)/\1/g\" -e 's/\t/ /g' -e 's/ *$//g' -e 's/^ *//g'`";
				return 0;
			fi
		fi
	else
		let cnt=cnt+1
	fi	
  done < "$FILE"
    
}

# Set a value in a *.cfg file
#  $1=file.cfg
#  $2=Section (without [])
#  $3=Key (key=)
#  $4=Value (=Value)
#
set_cfg_value() {

  FILE="$1"
  SECTION="$2"
  KEY="$3"
  VALUE="$4"

  let in_section=0
  let replaced=0

  if [ -z "$SECTION" ]; then
	let in_section=1
	COMMENTARY="#.*"
  else
	COMMENTARY="\/\/.*"	
  fi

  while read line;
  do
	if [ $replaced -eq 0 ];
	then
		# check, if we are leave section --> return
		if [ $in_section -eq 1 ]; then
			check_out_section=`echo "$line" | sed -r "s/\[.*\]/OK/g"`
			if [ "$check_out_section" = "OK" ]; then let in_section=2; fi
		fi
	
		# check, if we enter the section
		if [ $in_section -eq 0 ]; then
			if [ "$line" = "[$SECTION]" ]; then let in_section=1; fi
		fi
	
		if [ $in_section -eq 1 ]; then
			CFG_VALUE=`echo "$line" | grep -E "^$KEY="`; 		
			if [ ! -z "$CFG_VALUE" ]; then
				COMMENT=`echo "$line" | sed "s/.*\($COMMENTARY\)/\1/g"`
				if [ "$COMMENT" = "$line" ]; then COMMENT=""; fi

				echo "$KEY=$VALUE $COMMENT"
				let replaced=1
			fi
		fi
	fi

	if [ $replaced -eq 0 ] || [ $replaced -eq 2 ]; then
		echo "$line";
	else
		let replaced=2
	fi

  done < "$FILE" > "$FILE.new"

  if [ -f "$FILE.new" ]; then
	rm "$FILE"
	mv "$FILE.new" "$FILE"
  fi
}

# Check write permission and get $LOCKTEMPDIR for pipes. 
get_locktempdir() {
	LOCKTEMPDIR=`touch /var/tmp/$SRC_ID-$$.lock 2>&1`
	if [ ! -z "$LOCKTEMPDIR" ]; then LOCKTEMPDIR="/tmp"; else LOCKTEMPDIR="/var/tmp"; rm $LOCKTEMPDIR/$SRC_ID-$$.lock; fi
}
