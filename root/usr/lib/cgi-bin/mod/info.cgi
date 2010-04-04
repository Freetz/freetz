#!/bin/sh

PATH=/mod/bin:/mod/usr/bin:/mod/sbin:/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin
. /etc/freetz_info.cfg

let _width=$_cgi_width-254
divstyle="style='margin-top:6px;'"

sec_begin '$(lang de:"Firmware-Informationen" en:"Information about firmware")'
 echo -n '<div '$divstyle'><b>$(lang de:"Boxtyp" en:"Box type"):</b> '$FREETZ_INFO_BOXTYPE'&nbsp;&nbsp;'
 echo -n '<b>$(lang de:"AVM-Firmwareversion:" en:"AVM firmware version:")</b> '$FREETZ_INFO_FIRMWAREVERSION'&nbsp;&nbsp;'
 echo '<b>$(lang de:"Sprache:" en:"Language:")</b> '$FREETZ_INFO_LANG'</div>'
 if [ -r /proc/version ]; then
	_kernelversion="$(cat /proc/version | sed -e 's/Linux version //;s/#.*//')"
 else
	_kernelversion=""
 fi
 if [ ! -z "$_kernelversion" ]; then
	echo '<div '$divstyle'><b>Kernel$(lang de:"version" en:" version"):</b> '$_kernelversion'</div>'
 fi
 echo '<div '$divstyle'><b>FREETZ$(lang de:"-Version" en:" version"):</b> '$FREETZ_INFO_SUBVERSION'</div>'
date_de_format=$(echo "$FREETZ_INFO_MAKEDATE" \
		| sed -re 's/([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})(.*)/\3.\2.\1 \4\:\5\:\6/')
 echo '<div '$divstyle'><b>$(lang de:"Erstellungsdatum" en:"Creation date"):</b> '$date_de_format'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Urspr&uuml;nglicher Dateiname" en:"Initial file name"):</b><br>'$FREETZ_INFO_IMAGE_NAME'</div>'
 if [ ! -z "$FREETZ_INFO_COMMENT" ]; then
	echo '<div '$divstyle'><b>$(lang de:"Benutzerdefinierte Informationen" en:"User defined information"):</b><br>'
	echo "$FREETZ_INFO_COMMENT</div>"
 fi
sec_end

print_entry() {
	local type=$1 name=$2 sub=$3
	if [ -n "$sub" ]; then
		if [ "$name" = "$open_entry" ]; then
			echo "<small>&gt; $sub</small><br>"
		else
		    	print_entry "$type" "${name}_$sub"
		fi
	else
		echo "$name<br>"
		open_entry=$name
	fi
}
#
# Read (and print) all following entries with the desired type.
# Leave the last line read for the next invocation.
# Types START and END are used as markers.
#
read_entries() {
	local sel=$1 open_entry=
	while [ "$type" = "$sel" -o "$type" = START ]; do
		if [ "$type" = "$sel" ]; then
			print_entry "$type" "$entry" "$subentry"
		fi
		read -r sort type entry subentry || type=END
	done
}
# 
# Preprocess, classify and sort configuration variables
# Output format: "$sortkey $type $entry [$sub_entry]"
# Examples:      "20 pkg dropbear disable_host_lookup"
#                "50 rem assistant"
# Entries with the same $type shall have the same $sortkey.
#
preprocess_conf() {
    	local file=$1
	local lowercase="y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;"
	sed -nr "
		s/=y$//
		s/^FREETZ_//
		/^EXTERNAL/ d
		/^(PATCH|USBSTORAGE|AUTOMOUNT|AUTORUN)_/ {
			s/^(USBSTORAGE|PATCH)_//
			s/_/ / # separate sub-option
			$lowercase
			s/^/10 pat /; p; d
		}
		/^REMOVE_/ {
			s/^REMOVE_//
			$lowercase
			s/^/50 rem /; p; d
		}
		/^MODULE_/ {
			s/^MODULE_//
			s/^/30 mod /; p; d
		}
		/^LIB_/ {
			s/LIB_//
			s/^/40 lib /; p; d
		}
		/^PACKAGE_.*_CGI$/ {
			s/^PACKAGE_(.*)_CGI$/\1/
			/_/ d # why?
			$lowercase
			s/^/60 cgi /; p; d
		}
		/^PACKAGE/ {
			s/^PACKAGE_//
			s/_/ /
			$lowercase
			s/^/20 pkg /; p; d
		}
	" "$file" | sort
}
#
# Format output; the order in which read_entries is called must match the sort
# order above
#
format_conf() {
	type=START
	sec_begin '$(lang de:"FREETZ-Konfiguration" en:"FREETZ configuration")'
	cat <<- 'EOF'
	<table id="freetz-conf" border="0">
	<tr>
		<th>$(lang de:"Patches" en:"Patches"):</th>
		<th>$(lang de:"Pakete" en:"Packages"):</th>
		<th>$(lang de:"Module" en:"Modules"):</th>
		<th>$(lang de:"Libraries" en:"Libraries"):</th>
	</tr>
	<tr>
	EOF
	echo '<td>'; read_entries pat; echo '</td>'
	echo '<td rowspan="3">'; read_entries pkg; echo '</td>'
	echo '<td>'; read_entries mod; echo '</td>'
	echo '<td rowspan="3">'; read_entries lib; echo '</td>'
	cat <<- 'EOF'
	</tr>
	<tr>
		<th>$(lang de:"Entfernt" en:"Removes"):</th>
		<th>$(lang de:"CGI-Pakete" en:"CGI Packages"):</th>
	</tr>
	<tr>
	EOF
	echo '<td>'; read_entries rem; echo '</td>'
	echo '<td>'; read_entries cgi; echo '</td>'
	cat <<- EOF
	</tr>
	</table>
	<div $divstyle><br><a href="$(href extra mod do_download_config)"><b>.config:</b></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="$(href extra mod do_download_config)">$(lang de:"Herunterladen als Textdatei" en:"Download as text file")</a></div>
	EOF
	echo -n "<pre style='overflow: auto; width: ${_width}px; max-height: 100px;'>"
	html < /etc/.config
	echo '</pre>'
	sec_end
}
#
# Put everything together
#
if [ -r /etc/.config ]; then
#    	echo "<pre>"; preprocess_conf /etc/.config | html; echo "</pre>"
	preprocess_conf /etc/.config | format_conf
fi

if [ ! -z "$FREETZ_INFO_EXTERNAL_FILES" ]; then
	sec_begin '$(lang de:"Ausgelagerte Dateien" en:"Externalised files")'
		echo -n "<pre style='overflow: auto; width: ${_width}px; max-height: 100px;'>"
		echo -n "$FREETZ_INFO_EXTERNAL_FILES"
		echo '</pre>'
	sec_end
fi
