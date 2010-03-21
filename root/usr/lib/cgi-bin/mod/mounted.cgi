#!/bin/sh
ERRORFILE=/tmp/mounted.err
DEBUG_PATH=
# DEBUG_PATH=/mod/root/

eval "$(modcgi cmd:path mounted)"

do_remount() {
	mount -o remount "$@" 2> "$ERRORFILE"
}

do_unmount() {
	sec_begin '$(lang de:"Unmount-Meldungen" en:"Unmount messages")'
	echo "<pre class='plain'>"
	/etc/hotplug/storage unplug "$MOUNTED_PATH" 2> "$ERRORFILE" | html
	echo "</pre>"
	sec_end
}

errpath=""
if [ "$sec_level" -eq 0 -a -n "$MOUNTED_CMD" ]; then
	case $MOUNTED_CMD in
		R)       do_remount -r "$MOUNTED_PATH" ;;
		W)       do_remount -w "$MOUNTED_PATH" ;;
		unmount) do_unmount "$MOUNTED_PATH" ;;
	esac
	if [ -r "$ERRORFILE" ]; then
		errpath=$MOUNTED_PATH
	fi
fi

# actions=true if action buttons are to be displayed
if [ "$sec_level" -eq 0 ]; then
	actions=true
else
	actions=false
fi
# The status page is called both as /cgi-bin/status.cgi and /cgi-bin/index.cgi
if [ "$SCRIPT_NAME" != /cgi-bin/pkgstatus.cgi ]; then
	[ "$MOD_MOUNTED_UMOUNT" != "yes" ] && actions=false
fi
formact=$(html "$SCRIPT_NAME${QUERY_STRING:+?$QUERY_STRING}")

sec_begin '$(lang de:"Eingeh&auml;ngte Partitionen" en:"Mounted partitions")'

format_size() {
	echo "$1B" | sed -e 's/[KMGT]\?B/ &/; s/KB$/kB/'
}
format_path() {
	echo "$1" | sed -e 's#/#/\&shy;#g'
}

print_mountpoints() {
	while read -r fstyp mountopts device path; do
		echo "$DFOUT" | sed -ne "\#$path# { s/\(% [^ ]*\) /\1\n/g; p; q}" | 
		while read -r device total used free percent path; do
			print_mp
		done
	done
}

print_mp() {
	case "$fstyp=$device" in
		fuse=http*) fstyp="davfs" ;;
		fuseblk=*)  fstyp="ntfs" ;;
	esac
	total=$(format_size "$total")
	used=$(format_size "$used")
	free=$(format_size "$free")
	percent=${percent%\%}
	case $mountopts in
		ro*) actstatus=o ;;
		rw*) actstatus=w ;;
	esac
	showpath=$(format_path "$path")
	showdev=$(format_path "$device")
	rdisabled=$disabledbtn
	wdisabled=$disabledbtn
	if [ "$actstatus" = "w" ]; then
		barstyle="rw"
		newstatus="r"
		$actions && rdisabled=''
	else
		barstyle="ro"
		newstatus="w"
		$actions && wdisabled=''
	fi
	echo "<tbody class='$barstyle'>"
	echo -n "<tr>"
	echo -n "<td class='path'>$showpath</td><td class='device'>$showdev</td>"
	echo -n "<td class='fstype'>$fstyp</td>"
	echo -n '<td class='actions'>'
	$actions && echo -n '<small>$(lang de:"Mountoptionen" en:"Mount options"):</small>'
	echo '</td></tr>'
	echo -n "<tr><td colspan='3' class='free'>${used} $(lang de:"von" en:"of") ${total} $(lang de:"belegt" en:"used"), ${free} $(lang de:"frei" en:"free")</td>"
	echo '<td colspan="1" class="actions">'
	echo "<form class='btn' action='$formact' method='post'>"
	echo "<input type='hidden' name='path' value='$(html "$path")'>"
	echo "<input class='button' type='submit' name='cmd' value='R' $rdisabled>"
	echo "<input class='button' type='submit' name='cmd' value='W' $wdisabled>"
	if $actions; then
		echo "<input type='submit' name='cmd' value='unmount'>"
	fi
	echo '</form>'
	echo '</td></tr>'
	if [ "$errpath" = "$path" -a -r "$ERRORFILE" ]; then
		echo "<tr><td colspan='4'>"
		echo "<pre class='plain error'>"
		html < "$ERRORFILE"
		echo "</pre>"
		echo "</td></tr>"
	fi
	echo "<tr><td colspan='4'>"
	stat_bar $barstyle $percent
	echo "</td></tr>"
	echo "</tbody>"
}

disabledbtn="disabled='disabled' "
DFOUT=$("$DEBUG_PATH"df -h | sed -n '1d; :a; $!N; $!ba; s/\n  */ /g;p')
mfilt=$("$DEBUG_PATH"mount |
	sed -rn '
		\#^/dev/(sd|mapper/)|^https?://|^.* on .* type (jffs|fuse|cifs)|^.*:/.* on .* type nfs# {
			s/^([^ ]+) on (.*) type ([^ ]*) \(([^)]*)\)$/\3 \4 \1 \2/; p
		}
	'
)
if [ -z "$mfilt" ]; then
	echo "<p>$(lang de:"Keine gefunden" en:"none found")</p>"
else
	echo '<table class="mounted">'
	echo "$mfilt" | print_mountpoints
	echo "</table>"
fi
sec_end

rm -f "$ERRORFILE"
# vim: set ts=4:
