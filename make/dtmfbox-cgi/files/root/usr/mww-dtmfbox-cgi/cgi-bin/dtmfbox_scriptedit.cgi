#!/bin/sh
#####################################################################

# usb or not?
if [ "$DTMFBOX_PATH" = "" ] || [ "$DTMFBOX_PATH" = "/var/dtmfbox" ] || [ "$DTMFBOX_PATH" = "/var/dtmfbox-bin" ]; then
  GOT_USB=0
else
  GOT_USB=1
fi

CONFIG_FILES="/var/dtmfbox/dtmfbox.cfg /var/dtmfbox/menu.cfg /var/dtmfbox/script.cfg"
SCRIPT_FILES="/var/dtmfbox/script/*.sh"

FILE_UUE="dtmfbox_data.uue"
FILE_STATUS=""

DEBUG_CFG="/var/flash/debug.cfg"
DEBUG_CFG_TMP="/var/tmp/debug_cfg.tmp"
BOOT_CFG="$DTMFBOX_PATH/boot.sh"

if [ "$TEXTAREA_ROWS" = "" ]; then TEXTAREA_ROWS="20"; fi
if [ "$TEXTAREA_WRAP" = "" ]; then TEXTAREA_WRAP="off"; fi

generate_bootfile() {

#####################################################################

FILE_START_TAG="########## -= dtmfbox settings - DO NOT EDIT - S =- ##########"
FILE_END_TAG="########## -= dtmfbox settings - DO NOT EDIT - E =- ##########"
FILE_START_TAG_MKDIR="mkdir -p /var/tmp 2>/dev/null"
FILE_START_TAG_DATA="cat > /var/tmp/$FILE_UUE << 'END_DTMFBOX_DATA'"
FILE_END_TAG_DATA="END_DTMFBOX_DATA"

#####################################################################

FILE_START_VARIABLES="
export DTMFBOX_PATH='$DTMFBOX_PATH'
export DTMFBOX_ENABLED='$DTMFBOX_ENABLED'
export DTMFBOX_WEBIF_PASS='`cat /var/dtmfbox/httpd/httpd.conf 2>/dev/null`'
export DTMFBOX_VERSION='$DTMFBOX_VERSION'
export DTMFBOX_WWW='$DTMFBOX_WWW'
export DTMFBOX_WWW_DL_FILE='$DTMFBOX_WWW_DL_FILE'
if [ \"\$DTMFBOX_PATH\" = \"\" ] || [ \"\$DTMFBOX_PATH\" = \"/var/dtmfbox\" ]; then DTMFBOX_PATH=\"/var/dtmfbox-bin\"; fi"

#####################################################################

FILE_START_PING="
if [ \"\$DTMFBOX_PATH\" = \"/var/dtmfbox-bin\" ] || [ ! -f \"\$DTMFBOX_PATH/rc.dtmfbox\" ];
then
	mkdir -p \"\$DTMFBOX_PATH\"
	cd \"\$DTMFBOX_PATH\"

	# wait, till internet connection is ready
	let cnt=0;
	while !(ping -c 1 fritz.v3v.de); do
		if [ \$cnt -eq 30 ]; then break; fi
		let cnt=cnt+1;
		sleep 10
	done

	# wget rc.dtmfbox
	wget \"\$DTMFBOX_WWW/rc.dtmfbox\"
	chmod +x ./rc.dtmfbox

	# wget busybox-tools
	./rc.dtmfbox check_busybox
	if [ ! -s /var/tmp/busybox-tools ]; then
		wget \"\$DTMFBOX_WWW/busybox-tools\"
		chmod +x ./busybox-tools
	fi
fi"

#####################################################################

FILE_START_USB="(
 # USB-Mount (300 sec)
 let cnt=0;
 while [ ! -f \"$BOOT_CFG\" ]; do
	if [ \$cnt -eq 30 ]; then break; fi
	let cnt=cnt+1;
	sleep 10
 done;
)
sleep 30; sh \"$BOOT_CFG\""

#####################################################################

if [ "$FREETZ" = "0" ];
then
	RC_PREFIX="."
else
	RC_PREFIX="/etc/init.d"
fi

FILE_START="
mkdir -p \$DTMFBOX_PATH
cd \$DTMFBOX_PATH
if [ -f \"$RC_PREFIX/rc.dtmfbox\" ];
then
	rm /var/dtmfbox 2>/dev/null
	ln -sf "\$DTMFBOX_PATH" "/var/dtmfbox"
	export PATH=/var/dtmfbox:\$PATH

	# install dtmfbox
	$RC_PREFIX/rc.dtmfbox install bypath

	# decode/unpack configuration...
	$UUDECODE "/var/tmp/$FILE_UUE" | $GUNZIP -f -c | $TAR xv -C / -f -
	rm /var/tmp/$FILE_UUE 2>/dev/null

	# patch config and scripts
	if [ -f /var/dtmfbox/cfg.patch ]; then
		cp /var/dtmfbox/default/cfg/* /var/dtmfbox
		$PATCH < /var/dtmfbox/cfg.patch;
		rm /var/dtmfbox/cfg.patch
	fi

	cd \$DTMFBOX_PATH/script
	if [ -f /var/dtmfbox/script.patch ]; then
		cp /var/dtmfbox/default/script/* /var/dtmfbox/script
		$PATCH < /var/dtmfbox/script.patch;
		rm /var/dtmfbox/script.patch
	fi
	chmod +x /var/dtmfbox/script/*
	cd \$DTMFBOX_PATH

	# start webinterface (set password)
	if [ ! -z \"\$DTMFBOX_WEBIF_PASS\" ]; then echo \"\$DTMFBOX_WEBIF_PASS\" > /var/dtmfbox/httpd/httpd.conf; fi
	$RC_PREFIX/rc.dtmfbox start_httpd

	# start dtmfbox
	if [ \"\$DTMFBOX_ENABLED\" = \"1\" ]; then $RC_PREFIX/rc.dtmfbox start; fi
fi"
}

#####################################################################

do_compress() {

  if [ "$PATCHDIFF" = "1" ];
  then
	# does busybox have patch and diff?
	HAS_DIFF=`$DIFF --help 2>&1 | $HEAD -n 1 | grep "not found"`
        HAS_PATCH=`$PATCH --help 2>&1 | $HEAD -n 1 | grep "not found"`
  else
	HAS_DIFF="NO"
	HAS_PATCH="NO"
  fi

  # create patches and compress them (Diff + Patch + GZip)
  if [ -z "$HAS_DIFF" ] && [ -z "$HAS_PATCH" ];
  then
	  rm /var/dtmfbox/script.patch /var/dtmfbox/cfg.patch 2>/dev/null
	  $DIFF -Naur /var/dtmfbox/default/script /var/dtmfbox/script > /var/dtmfbox/script.patch
	  for var in $CONFIG_FILES; do
		if [ -f "$var" ]; then
			file=`echo $var | sed 's/.*\///g'`
			$DIFF -Naur /var/dtmfbox/default/cfg/$file $var >> /var/dtmfbox/cfg.patch
		fi
	  done

	  $TAR c -O /var/dtmfbox/script.patch /var/dtmfbox/cfg.patch 2>/dev/null | $GZIP -f - | $UUENCODE - > "/var/tmp/$FILE_UUE"
	  rm /var/dtmfbox/script.patch /var/dtmfbox/cfg.patch 2>/dev/null
  else
	# save GZipped (ALL_FILES --> TAR --> GZ --> UUE)
	$TAR c -O $CONFIG_FILES $SCRIPT_FILES 2>/dev/null | $GZIP -f - | $UUENCODE - > "/var/tmp/$FILE_UUE"
  fi

  if [ -f "/var/tmp/$FILE_UUE" ];
  then

  # recreate debug.cfg
  # search for start-tag/end-tag, remove old data and insert new.
  let START_FOUND=0
  let END_FOUND=0
  while read line;
  do
	if [ $START_FOUND -eq 0 ];
	then
		if [ "$FILE_START_TAG" = "$line" ]; then
			# start tag found! stop writing!
			let START_FOUND=1;
		else
			# no start tag found? then write to file...
			echo $line;
		fi
	fi

	if [ $START_FOUND -eq 1 ];
	then
		if [ "$FILE_END_TAG" = "$line" ]; then
			if [ $END_FOUND -eq 0 ];
			then
 				# insert new data
		          	if [ "$GOT_USB" = "0" ];
        		  	then
				 	echo "$FILE_START_TAG"
					echo "$FILE_START_TAG_MKDIR"
	 			  	echo "$FILE_START_TAG_DATA"
				  	cat "/var/tmp/$FILE_UUE"
				  	echo "$FILE_END_TAG_DATA"
				  	echo "$FILE_START_VARIABLES"
				  	if [ "$FREETZ" = "0" ]; then
						echo "$FILE_START_PING";
					fi
				  	echo "$FILE_START"
				  	echo "$FILE_END_TAG"
				else
			  		echo "$FILE_START_TAG"
 	      				echo "$FILE_START_USB"
		  			echo "$FILE_END_TAG"
				fi
			fi

			# resume writing...
			let START_FOUND=0
			let END_FOUND=1
		fi
	fi
  done < "$DEBUG_CFG" > "$DEBUG_CFG_TMP"

  # new? then add data to the end of the file
  if [ $END_FOUND -eq 0 ];
  then
	if [ "$GOT_USB" = "0" ];
        then
		echo "$FILE_START_TAG" 		>> "$DEBUG_CFG_TMP"
		echo "$FILE_START_TAG_DATA" 	>> "$DEBUG_CFG_TMP"
		echo "$FILE_START_TAG_MKDIR"	>> "$DEBUG_CFG_TMP"
		cat "/var/tmp/$FILE_UUE" 	>> "$DEBUG_CFG_TMP"
		echo "$FILE_END_TAG_DATA" 	>> "$DEBUG_CFG_TMP"
		echo "$FILE_START_VARIABLES"	>> "$DEBUG_CFG_TMP"
 	      	if [ "$FREETZ" = "0" ]; then
			echo "$FILE_START_PING"	>> "$DEBUG_CFG_TMP";
		fi
 	      	echo "$FILE_START"		>> "$DEBUG_CFG_TMP"
		echo "$FILE_END_TAG" 		>> "$DEBUG_CFG_TMP"
	else
  		echo "$FILE_START_TAG" 		>> "$DEBUG_CFG_TMP"
 	      	echo "$FILE_START_USB"		>> "$DEBUG_CFG_TMP"
		echo "$FILE_END_TAG" 		>> "$DEBUG_CFG_TMP"
	fi
  fi

  if [ "$GOT_USB" = "1" ];
  then
		echo "$FILE_START_TAG" 		> "$BOOT_CFG"
		echo "$FILE_START_TAG_MKDIR" 	>> "$BOOT_CFG"
		echo "$FILE_START_TAG_DATA" 	>> "$BOOT_CFG"
		cat "/var/tmp/$FILE_UUE" 	>> "$BOOT_CFG"
		echo "$FILE_END_TAG_DATA" 	>> "$BOOT_CFG"
	    	echo "$FILE_START_VARIABLES"	>> "$BOOT_CFG"
 	    	if [ "$FREETZ" = "0" ]; then
			echo "$FILE_START_PING"	>> "$BOOT_CFG";
		fi
 	    	echo "$FILE_START"		>> "$BOOT_CFG"
		echo "$FILE_END_TAG" 		>> "$BOOT_CFG"
  fi

  # calculate file sizes
  FILE_UCMP_SIZE="`$DU -c -h $CONFIG_FILES $SCRIPT_FILES | grep 'total' | sed -r 's/(.*)\t.*/\1/g'`"
  FILE_CMP_SIZE="`$DU -c -h /var/tmp/$FILE_UUE | grep 'total' | sed -r 's/(.*)\t.*/\1/g'`"
  FILE_STATUS="Gespeichert: $FILE_UUE - Total: $FILE_UCMP_SIZE, GZip: $FILE_CMP_SIZE"

  let FILE_SIZE_DEBUG="`$DU $DEBUG_CFG_TMP | sed -r 's/(.*)\t.*/\1/g'`"
  let FILE_SIZE_DEBUG=$FILE_SIZE_DEBUG*1024

  if [ $FILE_SIZE_DEBUG -ge $DTMFBOX_MAX_SAVE_LIMIT ];
  then
    	  # maximum file size reached! Abort!
          FILE_STATUS="<font color='red'><b>Fehler! Maximale Größe der /var/flash/debug.cfg erreicht! Erlaubt: $DTMFBOX_MAX_SAVE_LIMIT Bytes, Aktuell: $FILE_SIZE_DEBUG Bytes</b></font>"
  else
	  # check for changes in /var/flash/debug.cfg
	  F1="`cat $DEBUG_CFG_TMP`"
	  F2="`cat $DEBUG_CFG`"

	  FILE_STATUS="$FILE_STATUS<br>"

	  if [ "$F1" != "$F2" ];
	  then
	  	# save new debug.cfg ...
		cat "$DEBUG_CFG_TMP" > "$DEBUG_CFG"
		FILE_STATUS="$FILE_STATUS <font size=1>$DEBUG_CFG gespeichert!</font><br>"

		if [ "$GOT_USB" = "1" ]; then
			FILE_STATUS="$FILE_STATUS <font size=1>$BOOT_CFG gespeichert!</font><br>"
		fi
	  else
	        # no changes ...
		if [ "$GOT_USB" = "1" ]; then
			FILE_STATUS="$FILE_STATUS <font size=1>$BOOT_CFG gespeichert!</font><br>"
		else
			FILE_STATUS="$FILE_STATUS <font size=1>$DEBUG_CFG unverändert!</font><br>"
		fi
	  fi
  fi

  # ... and remove temporary files
  rm "$DEBUG_CFG_TMP" 2>/dev/null
  rm "/var/tmp/$FILE_UUE" 2>/dev/null

  else
    FILE_STATUS="<font color='red'><b>Fehler! $FILE_UUE kann nicht erzeugt werden!</font>"
  fi
}

#####################################################################

do_uninstall() {

  # get $FILE_START_TAG and $FILE_END_TAG
  generate_bootfile

  # recreate debug.cfg
  # search for start-tag/end-tag and remove data
  let START_FOUND=0
  let END_FOUND=0
  while read line;
  do
	if [ $START_FOUND -eq 0 ];
	then
		if [ "$FILE_START_TAG" = "$line" ]; then
			# start tag found! stop writing!
			let START_FOUND=1;
		else
			# no start tag found? then write to file...
			echo $line;
		fi
	fi

	if [ $START_FOUND -eq 1 ];
	then
		if [ "$FILE_END_TAG" = "$line" ]; then
			# resume writing...
			let START_FOUND=0
			let END_FOUND=1
		fi
	fi
  done < "$DEBUG_CFG" > "$DEBUG_CFG_TMP"
  cat "$DEBUG_CFG_TMP" > "$DEBUG_CFG"
}

#####################################################################

do_save() {
      # save required variables, that gets overwritten by script.cfg
      TMP_DIRECT_EDIT="$DIRECT_EDIT"
      TMP_DTMFBOX_PATH="$DTMFBOX_PATH"

      # Reload (webinterface) settings
      if [ "$FILE_EDIT" = "/var/dtmfbox/script.cfg" ]; then
	. $FILE_EDIT
      fi

      # restore dtmfbox path!!
      DTMFBOX_PATH="$TMP_DTMFBOX_PATH"

      if [ "$DTMFBOX_APACHE" != "1" ]; then

	      # generate text for bootfile
	      generate_bootfile

	      # compress data and save to flash
	      do_compress;

      else
	      FILE_STATUS="Einstellungen gespeichert!"
      fi

      # restore edit mode!!
      DIRECT_EDIT="$TMP_DIRECT_EDIT"
}

# read post variables
read -r recv_data
recv_data=`echo $recv_data | sed -e 's/&/ /g'`

# other file selected?
for var in $recv_data; do
	FILE_SELECT=$(echo $var | grep 'ffile_sel=' | sed -e 's/ffile_sel\=//' -e 's/\&.*//g')
	FILE_SELECT=$(echo "$FILE_SELECT" | sed -e "s/%0D//g" -e "s/%0A/\n/g")
	FILE_SELECT=$($HTTPD -d "$FILE_SELECT")

	# selected another file?
	if [ "$FILE_SELECT" != "" ];
	then
		FILE_EDIT="$FILE_SELECT"
		FILE_STATUS="`$DU -h $FILE_SELECT`"
	fi

	# selected another section?
	if [ "$SECT_SELECT" = "" ];
	then
		SECT_SELECT=$(echo $var | grep 'fsect_sel=' | sed -e 's/fsect_sel\=//' -e 's/\&.*//g')
		SECT_SELECT=$(echo "$SECT_SELECT" | sed -e "s/%0D//g" -e "s/%0A/\n/g")
		SECT_SELECT=$($HTTPD -d "$SECT_SELECT")
	fi

	# restart dtmfbox?
	if [ "$DTMFBOX_REBOOT" != "dtmfbox_reboot" ];
	then
		DTMFBOX_REBOOT=$(echo $var | grep 'check_reboot=' | sed -e 's/check_reboot\=//' -e 's/\&.*//g')
		DTMFBOX_REBOOT=$(echo "$DTMFBOX_REBOOT" | sed -e "s/%0D//g" -e "s/%0A/\n/g")
		DTMFBOX_REBOOT=$($HTTPD -d "$DTMFBOX_REBOOT")
		if [ "$DTMFBOX_REBOOT" = "dtmfbox_reboot" ]; then
			CHECK_REBOOT="1";
		else
			if [ "$CHECK_REBOOT" = "" ]; then CHECK_REBOOT="0"; fi
			if [ "$CHECK_REBOOT" = "1" ]; then CHECK_REBOOT="0"; fi
		fi
	fi
done

# select first file, if none is selected
if [ "$FILE_EDIT" = "" ]; then
	for var in $SCRIPT_FILES $CONFIG_FILES; do
		if [ -f "$var" ]; then
			FILE_SELECT="$var"
			FILE_EDIT="$var"
			FILE_STATUS="`$DU $FILE_SELECT`"
			break;
		fi
	done
fi
if [ "$FILE_POS" = "" ]; then FILE_POS="0"; fi
if [ "$FILE_STATUS" = "" ]; then FILE_STATUS="$FILE_EDIT"; fi

# save changes
for var in $recv_data; do
  if [ "$FILE_DATA" = "" ]; then

    # convert data
    FILE_DATA=$(echo $var | grep 'edit=' | sed -e 's/edit\=//' -e 's/\&.*//g')
    FILE_DATA=$(echo "$FILE_DATA" | sed -e "s/%0D//g" -e "s/%0A/\n/g")
    FILE_DATA=$($HTTPD -d "$FILE_DATA")

    if [ "$FILE_DATA" != "" ];
    then
      # save modifications to file
      echo "$FILE_DATA" > "$FILE_EDIT"
      chmod +x "$FILE_EDIT"

      do_save
    fi
  fi
done

#####################################################################

# $1=UNINSTALL
# uninstall dtmfbox (by script)
if [ "$1" = "UNINSTALL" ]; then
	do_uninstall;
	return 1;
fi;

# $1=SAVE
# save changes (by script)
if [ "$1" = "SAVE" ]; then
	do_save
	return 1;
fi

#####################################################################

if [ "$FULLSCREEN" != "1" ];
then
	echo "<table border='0' cellpadding='3' cellspacing='0' width='95%' bordercolor='#005588'>"
	echo "  <tr><td style='background-color:#005588'><font size='2' color='white'><b>$FILE_STATUS</b></font></td></tr>"
	echo "</table>"
fi

echo "<form name='ffile'  method='post'>"
echo "<input type='hidden' name='dummy' value='0'>"

cat << EOF
<script language='javascript'>
	function trim(val)
	{
		return val.replace(/ +/g, ' ').replace(/^\s+/g, '').replace(/\s+$/g, '');
	}

	function comment_opts(comment, opt, remove_comment)
	{
		var regex="/(.*)(\\\[" + opt + ":([^\\\]]+)\\\])(.*)/g";
		var retval = '';

		if(comment.match(eval(regex))) {
			if(!remove_comment)
				retval = comment.replace(eval(regex), "\$3");
			else
				retval = comment.replace(eval(regex), "\$1 \$4");
		}

		return retval;
	}

	function parse_text(comment_prefix, add_quotes)
	{
		var text=document.forms.feditor.edit.value;
		var lines = text.split("\n");				// split rows
		var i;
		var in_section = "";
		var in_range = "";
		var section = "";
		var last_value_pos = 0;
		var firstSection = true;

		comment_prefix = comment_prefix.replace(/\//g, "\\\/");	// escape comment

		document.write("<div id='sections_div'><table border='0' width='95%'><tr><td width='85px'><b>Bereich </b></td> <td><select id='sections' name='sections' onchange='javascript:on_section_change(this)'></select></td></tr></table><br></div>");

		for(i=0; i<lines.length; i++)				// walkthrough rows
		{
	  	  var comment = '';

		  lines[i] = lines[i].replace(/\r/g, "");		// remove 0x13

		  // [SECTION:...]
		  var groupsection = comment_opts(trim(lines[i]), "SECTION", false);

 		  // [HTML:...]
		  var html = comment_opts(trim(lines[i]), "HTML", false);
 		  if(html.length) {
			lines[i] = comment_opts(trim(lines[i]), "HTML", true);

			// The only line? Then show directly obove setting. Otherwise show html right after the setting
			if(trim(lines[i].replace(eval('/.*' + comment_prefix + '/'), "")).length == 0) {
				document.write(html);
				html = '';
			}
		  }

	 	  // remove comments!
		  if(lines[i].match(eval('/' + comment_prefix + '/')))
		  {
			comment = lines[i].replace(eval('/.*' + comment_prefix + '/'), "");
			lines[i] = lines[i].replace(eval('/' + comment_prefix + '.*/'), "");

		  }

 		  // [section], [SECTION:section] or EOF found?
		  if(lines[i].match(/\[.*\]/) || groupsection.length || i == lines.length-1)
		  {
			if(trim(lines[i]).length != 0 || groupsection.length)
			{
				in_section = trim(lines[i]);
				if(in_section.length == 0) in_section = groupsection;

				section = in_section.replace('[', '').replace(']', '');
				var newOption = document.createElement("option");
				newOption.appendChild(document.createTextNode(section));
				newOption.value = in_section;
				document.feditor2.sections.appendChild(newOption);
			}

			if("$SHOW_ADD_REMOVE" == "1" && !firstSection) {
				document.write("<br>");
				document.write("<table border='0' style='width:95%'><tr><td width='100px'><b>New </b></td><td>");
				document.write("<input type='button' style='font-size:10px' name='ADDMEN_" + i + "' style='width:78px' value='[menu:X]' onclick='javascript:on_sec_add(this, 0)'> ");
				document.write("<input type='button' style='font-size:10px' name='ADDSCR_" + i + "' style='width:78px' value='[script:X]' onclick='javascript:on_sec_add(this, 1)'> ");
				document.write("<input type='button' style='font-size:10px' name='ADDLIB_" + i + "' style='width:78px' value='[lib:X]' onclick='javascript:on_sec_add(this, 2)'> ");
				document.write("<input type='button' style='font-size:10px' name='ADDACT_" + i + "' style='width:78px' value='[action:X]' onclick='javascript:on_sec_add(this, 3)'> ");
				document.write("</td><td align='right'>");
				document.write("<input type='button' style='font-size:10px' name='SECDEL_" + i + "' style='width:150px' value='Delete " + (lines[last_value_pos].length > 13 ? lines[last_value_pos].substr(0, 10) + '...' : lines[last_value_pos]) + "' onclick='javascript:on_sec_del(this, " + last_value_pos + ")'><p>");
				document.write("<input type='button' style='font-size:10px' name='ADD_" + last_value_pos + "' style='width:150px' value='Add key=value' onclick='javascript:on_text_add(this, " + add_quotes + ")'>");
				document.write("</td></tr></table>");
			}

			document.write("</div>");
			document.write("<div id='" + in_section + "' style='display:none'>");

			firstSection = false;
			last_value_pos=i;
		  }

		  document.write("<table border='0' cellpadding='3' cellspacing='0' width='95%'>");

		  // key=value found!
		  if(!lines[i].match(/\[.*\]/))
		  {
			if(lines[i].length != 0)
			{
				var key = lines[i].replace(/=.*/g, "");
				var val = lines[i].replace(/.*=/g, "");
				val = trim(val); key = trim(key);

				if(add_quotes)
					val = val.replace(/\"(.*)\"/g, "\$1");

				// [OPTION:value1|caption1,value2|caption2,...]
				var options = comment_opts(comment, "OPTION", false);

				// [ONCANGE:function()]
				var option_change = comment_opts(comment, "ONCHANGE", false);
				if(option_change.length) comment = comment_opts(comment, "ONCHANGE", true);

				// [HIDE]
				var hide = comment_opts(comment, "HIDE", false);

				// [TYPE:xxx]
				var type  = comment_opts(comment, "TYPE", false);
				if(type.length) comment = comment_opts(comment, "TYPE", true);
				else type = 'text';

				// [WIDTH:xxx]
				var width = comment_opts(comment, "WIDTH", false);
				if(width.length) comment = comment_opts(comment, "WIDTH", true);
				else width = '85%';

				if(!comment.length)
					comment = key;

				// if("$FREETZ" == "1")
				//    col1_width='180px';
				// else
    				    col1_width='300px';

				var ctrl_id = (section.length > 0 ? section + "_" + key : key)

				if(hide!='1' && options.length)
				{
					comment = comment_opts(comment, "OPTION", true);

					document.write("<tr>");
					document.write("<td width='" + col1_width + "'>" + comment + "</td> <td>");
					document.write("<select id='" + ctrl_id + "' name='" + key + "_CFGLINE_" + i + "' onchange=\"javascript:on_text_change(this, '" + comment_prefix + "', " + add_quotes + ");" + option_change + "\">");

					var opts = options.split(",");
					var j;

					for(j=0; j<opts.length; j++) {
						var opts2 = opts[j].split("|");
						val_selected = "";
						if(opts2[0] == val) val_selected = "selected";

						document.write("<option value='" + opts2[0] + "' " + val_selected + ">" + opts2[1] + "</option>");
					}
					document.write("</select>" + html + "</td><td></td>");
					document.write("</tr>");
				}

				else if(hide!='1') {

					if("$SHOW_ADD_REMOVE" == "1")
						col1_width="100px"

					document.write("<tr>");
					document.write("<td width='" + col1_width + "'>" + comment +  "</td>");
					document.write("<td><input type='" + type + "' id='" + ctrl_id + "' name='" + key + "_CFGLINE_" + i + "' value='" + val + "' onchange=\"javascript:on_text_change(this, '" + comment_prefix + "'," + add_quotes + ");" + option_change + "\" style='width:" + width + "'>");
					document.write(html + "</td>");

					if("$SHOW_ADD_REMOVE" == "1") {
						document.write("<td width='115px' align='center'>");
						document.write("<input type='button' style='font-size:10px' name='ADD_" + i + "' style='width:35px' value='INS' onclick='javascript:on_text_add(this, " + add_quotes + ")'> ");
						document.write("<input type='button' style='font-size:10px' name='REN_" + i + "' style='width:35px' value='REN' onclick='javascript:on_text_rename(this, " + add_quotes + ")'> ");
						document.write("<input type='button' style='font-size:10px;width:35px' name='DEL_" + i + "' value='DEL' onclick='javascript:on_text_delete(this)'> ");
						document.write("</td>");
					} else {
						document.write("<td></td>");
					}

					document.write("</tr>");
				}
			}
		  }

		  document.write("</table>");
		}

		document.write("</div>");
	}


	function on_text_rename(obj, add_quotes)
	{
		var key_line = obj.name;
		var line = key_line.replace(/REN_/g, "");

		var text=document.forms.feditor.edit.value;
		var lines = text.split("\n");				// split rows

		new_val=prompt('Ändern:', lines[line]);
		if(new_val == null) return;

		lines[line] = new_val;
		text = lines.join("\n");
		document.forms.feditor.edit.value = text;
		//document.forms.feditor.submit();
		do_submit();

	}

	function on_text_delete(obj)
	{
		var key_line = obj.name;
		var line = key_line.replace(/DEL_/g, "");

		var text=document.forms.feditor.edit.value;
		var lines = text.split("\n");				// split rows

		if(confirm(lines[line] + '\n\n' + 'löschen?'))
		{
			lines.splice(line, 1);				// remove line from array
			text = lines.join("\n");
			document.forms.feditor.edit.value = text;
			//document.forms.feditor.submit();
			do_submit();
		}

	}

	function on_text_add(obj, add_quotes)
	{
		var key_line = obj.name;
		var line = key_line.replace(/ADD_/g, "");

		var text=document.forms.feditor.edit.value;
		var lines = text.split("\n");				// split rows

		new_key=prompt('"Schlüssel=Wert" eingeben:');
		if(new_key == null) return;
		if(!new_key.match(/=/)) { alert(new_key + ' ungültig!'); return; }

		if(confirm(new_key + '\n\n' + 'hinzufügen?'))
		{
			lines[line] = lines[line] + '\n' + new_key;

			text = lines.join("\n");
			document.forms.feditor.edit.value = text;
			//document.forms.feditor.submit();
			do_submit();
		}
	}

	function on_sec_del(obj, lastPos)
	{
		var key_line = obj.name;
		var line = key_line.replace(/SECDEL_/g, "");

		var text=document.forms.feditor.edit.value;
		var lines = text.split("\n");					 // split rows

		if(confirm(lines[lastPos] + '\n\n' + 'löschen?'))
		{
			lines.splice(lastPos, parseInt(line)-parseInt(lastPos)); // remove line from array
			text = lines.join("\n");
			document.forms.feditor.edit.value = text;
			do_submit();
		}
	}

	function on_sec_add(obj, type)
	{
		var key_line = obj.name;
		var line;
		var prefix;

		if(type==0) { line = key_line.replace(/ADDMEN_/g, ""); prefix='menu:'; }
		if(type==1) { line = key_line.replace(/ADDSCR_/g, ""); prefix='script:'; }
		if(type==2) { line = key_line.replace(/ADDLIB_/g, ""); prefix='lib:'; }
		if(type==3) { line = key_line.replace(/ADDACT_/g, ""); prefix='action:'; }

		var text=document.forms.feditor.edit.value;
		var lines = text.split("\n");				// split rows

		new_key=prompt('Namen eingeben:');
		if(new_key == null) return;

		if(confirm('[' + prefix + new_key + ']\n\n' + 'hinzufügen?'))
		{
			// [menu:X]
			if(type==0)
				lines[line] = '[' + prefix + new_key + ']\nsay=Menue ' + new_key + '.\n\n' + lines[line];

			// [script:X]
			if(type==1)
				lines[line] = '[' + prefix + new_key + ']\ncmd=/var/dtmfbox/script/' + new_key + '.sh(/var/dtmfbox/script/' + new_key + '.sh, "%type%", "%direction%", "%src_id%", "%dst_id%", "%src_no%", "%dst_no%", "%acc_id%", "%dtmf%")\n\n' + lines[line];

			// [lib:X]
			if(type==2)
				lines[line] = '[' + prefix + new_key + ']\nlibrary=libfoo.so\nfunction=bar("%type%", "%direction%", "%src_id%", "%dst_id%", "%src_no%", "%dst_no%", "%acc_id%", "%dtmf%")\n\n' + lines[line];

			// [action:X]
			if(type==3)
				lines[line] = '[' + prefix + new_key + ']\naction=\n\n' + lines[line];

			text = lines.join("\n");
			document.forms.feditor.edit.value = text;

			// Preselect
			var newOption = document.createElement("option");
			newOption.appendChild(document.createTextNode(prefix + new_key));
			newOption.value = '[' + prefix + new_key + ']';
			document.feditor2.sections.appendChild(newOption);
			document.getElementById('sections').value =  '[' + prefix + new_key + ']';

			// Submit
			do_submit();
		}
	}

	function on_text_change(obj, comment_prefix, add_quotes)
	{
		var key_line = obj.name;
		var key = key_line.replace(/_CFGLINE_.*/g, "");
		var line = key_line.replace(/.*_CFGLINE_/g, "");

		var text=document.forms.feditor.edit.value;
		var lines = text.split("\n");				// split rows
		var comment = '';

		comment_prefix_escaped = comment_prefix.replace(/\//g, "\\\/"); // escape comment

		// Re-Add comment
		if(lines[line].match(eval('/' + comment_prefix_escaped + '/')))
		{
		  var tmp = lines[line];
		  var i;
		  var startFound = false;
		  var endFound = 0;
		  var searchQuotes = false;

		  // try to find comment and cut it out
		  if(add_quotes) {
			  if(tmp.match(/.*=\\"/)) { searchQuotes=true; startFound = false; }
			  else startFound = true;
	          } else {
			startFound = true;
		  }

  		  for(i=1; i<tmp.length; i++)
		  {
			var c1 = tmp.substr(i-1, 1);
			var c2 = tmp.substr(i, 1);

			if(searchQuotes && (c1 != "\\\" && c2 == "\"")) {
				if(startFound) { endFound = i+1; break; }
				else { startFound = true; }
			}

			if(!searchQuotes && (c2 == ' ' || c2 == '\\t' || c2 == "\\n"))
			{
		 		if(startFound) {
					endFound = i;
					break;
				}
			}
		  }

		  if(endFound != 0)
			  comment = tmp.substr(endFound, tmp.length - endFound);
		}

		// Modify key=value, paste comment
		if(add_quotes)
		{
			var new_obj_val = obj.value.replace(eval('/' + comment_prefix_escaped + '.*/'), "");
			new_obj_val = new_obj_val.replace(/\\\"/g, '"').replace(/"/g, "\\\\\"");	// escape " character
			lines[line] = key + "=\"" + new_obj_val + "\"" + comment;
		}
		else
		{
			lines[line] = key + "=" + obj.value.replace(eval('/' + comment_prefix_escaped + '.*/'), "") + comment;
		}

		// Join text and modify textarea
		text = lines.join("\n");
		document.forms.feditor.edit.value = text;
	}

	function on_section_change(obj)
	{
		var secdiv = document.getElementById(obj.value);

		if(secdiv) {
			for(i=0; i<obj.options.length; i++) {
				var tmpdiv = document.getElementById(obj.options[i].value);
				if(tmpdiv) tmpdiv.style.display = 'none';
			}

			secdiv.style.display = 'block';
		}
	}
</script>
EOF

if [ "$SHOW_FILE_SELECTION" != "0" ];
then
	echo "<table border='0' cellpadding='0' cellspacing='0' width='95%'><tr><td>"
	echo "<select name='ffile_sel' onChange='javascript:submit()' style='width:100%'>"

	if [ "$SHOW_CONFIG_FILES" != "0" ];
	then
	  for var in $CONFIG_FILES; do
		if [ -f "$var" ]; then
			if [ "$FILE_EDIT" = "$var" ]; then file_selected="selected"; else file_selected=""; fi
	        	FILE=`echo "$var" | sed 's/\/var\/dtmfbox\//CONFIG>> /g'`
			echo "<option $file_selected value=\"$var\">$FILE</option>";
		fi
	  done
	fi

	if [ "$SHOW_SCRIPT_FILES" != "0" ];
	then
	  for var in $SCRIPT_FILES; do
		if [ -f "$var" ]; then
			if [ "$FILE_EDIT" = "$var" ]; then file_selected="selected"; else file_selected=""; fi
			echo "<option $file_selected value=\"$var\">$var</option>";
		fi
	  done
	fi
	echo "</select>"
	echo "</td><td align='right' width='130px'>"
	echo "<input type='button' style='font-size:10px;width:60px' value='Neu' onclick=\"javascript:prompt_file=prompt('Dateiname (ohne Endung):', 'scriptfile'); if(prompt_file == null) return; prompt_file = prompt_file.replace(/ /g, '_').replace(/'/g, '') + '.sh'; location.href='$MAIN_CGI&page=$PAGE&pid=$$&run_cmd=touch%20/var/dtmfbox/script/' + (prompt_file) + ' chmod%20%2Bx%20/var/dtmfbox/script/' + (prompt_file)\"> "
	echo "<input type='button' style='font-size:10px;width:60px' value='Löschen' onclick=\"javascript:if(confirm('$FILE_EDIT löschen?')) { location.href='$MAIN_CGI&page=$PAGE&pid=$$&run_cmd=rm%20$FILE_EDIT' } \">"
	echo "</td></tr></table>"

else
	echo "<input type='hidden' name='ffile_sel' id='ffile_sel' value='$FILE_SELECT'>"
	echo "<input type='hidden' name='fsect_sel' value='$SECT_SELECT'>"
fi
echo "<input type='hidden' name='dummy2' value='0'>"
echo "</form>"

echo "<form name='feditor' method='post'>"
echo "<div id='edit_div' style='display:none'>"
echo -n "<textarea name='edit' id='edit' style='width:95%' rows='$TEXTAREA_ROWS' cols='80' wrap='$TEXTAREA_WRAP'>"
cat "$FILE_EDIT" | sed 's/&/&amp;/g'
echo -n "</textarea>"

echo "<br>"
echo "</div>"

echo "<div style='display:none'>"
echo "<input type='hidden' name='dummy' value='0'>"
echo "<input type='hidden' name='ffile_sel' id='ffile_sel' value='$FILE_EDIT'>"
echo "<input type='hidden' name='fsect_sel' value='$SECT_SELECT'>"
echo "<input type='hidden' name='check_reboot' value='dtmfbox_reboot'>"
echo "<input type='hidden' name='dummy2' value='0'>"
echo "</div>"
echo "</form>"

if [ "$DIRECT_EDIT" = "0" ];
then
cat << EOF
<form name="feditor2">
<script language="javascript">

	if("$COMMENT_PREFIX" == "#") parse_text("$COMMENT_PREFIX", true);
	if("$COMMENT_PREFIX" == "//") parse_text("$COMMENT_PREFIX", false);

	document.getElementById('edit_div').style.display = 'none';
	if(document.getElementById('sections').options.length > 0) {
		try {
			var obj = document.getElementById('sections');
			if("$SECT_SELECT" != "")
				obj.value = "$SECT_SELECT";
			else
				obj.selectedIndex = 0;

			on_section_change(obj)
		} catch(e) {}
	} else {
		document.getElementById('sections_div').style.display = 'none';
	}
</script>
</form>
<br>
<table border='0' width='95%'>
<tr><td><div align='right'><a href='$MAIN_CGI&page=$PAGE&direct_edit=1'>Text-Editor</a></div></td></tr>
<tr><td><hr color='black' align='left'></td></tr>
</table>
EOF
else
cat << EOF
<script language="javascript">
	document.getElementById('edit_div').style.display = 'block';
</script>
<table border='0' width='95%'><tr><td>
EOF
if [ "$FULLSCREEN" != "1" ]; then
cat << EOF
<div align='right'><a href="javascript:void(0);" onclick="window.open('dtmfbox.cgi?pkg=dtmfbox&page=$PAGE&direct_edit=1&fullscreen=1', '', 'fullscreen=yes, scrollbars=yes, resize=no, toolbar=no, status=no, location=no, menubar=no')" target="_new">Vollbild</a> | <a href='$MAIN_CGI&page=$PAGE&direct_edit=0'>Text-Editor verlassen</a></div>
</td></tr></table>
EOF
fi
fi

cat << EOF
<script language="javascript">
	function do_submit()
	{
		var obj=document.getElementById('check_reboot');

		try {
			if(obj.checked) document.forms.feditor.check_reboot.value = "dtmfbox_reboot";
			else document.forms.feditor.check_reboot.value = "";
		} catch(e) {}

		try { document.forms.feditor.fsect_sel.value = document.getElementById('sections').value; } catch(e) {}
		try { this.ffile_sel = document.forms['ffile'].ffile_sel.value; } catch(e) {}
		document.forms.feditor.submit();
	}
</script>
EOF

echo "<table border='0' width='95%'><tr>"
echo "<td align='left'><input type='button' value='Speichern' style='width:100px' onclick=\"javascript:do_submit();\"></td>"
if [ "$SHOW_REBOOT" != "0" ];
then
  if [ "$CHECK_REBOOT" = "1" ]; then dtmfbox_reboot="checked"; else dtmfbox_reboot=""; fi
  if [ -z "$(pidof "dtmfbox")" ]; then dtmfbox_reboot=""; dtmfbox_status="<font color='red' size='1'><br><b>stopped</b></font>"; else dtmfbox_status="<font color='green' size='1'><br><b>running</b></font>"; fi
  echo "<td align='right'><input type='checkbox' id='check_reboot' name='check_reboot' value='dtmfbox_reboot' $dtmfbox_reboot>dtmfbox neu starten $dtmfbox_status</td>"
fi
echo "</tr></table>"
echo "<input type='hidden' name='dummy3' value='0'>"

# restart dtmfbox?
if [ "$DTMFBOX_REBOOT" = "dtmfbox_reboot" ];
then
	echo -n "<pre>"
	/var/dtmfbox/rc.dtmfbox restart
	echo -n "</pre>"
fi
