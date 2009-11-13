#!/bin/sh

eval "$(modcgi branding:pkg:cmd mod_cgi)"
if [ ! -z "$MOD_CGI_CMD" ]; then
	chkremount=$(echo "$MOD_CGI_CMD" | sed -n -e "s/^-[r,w].*/ok/p")
	chkumount=$(echo "$MOD_CGI_CMD" | sed -n -e "s/^\/.*/ok/p")
	if [ ! -z "$chkremount" ]; then
		eval "$(mount -o remount $MOD_CGI_CMD)"
	else
		if [ ! -z "$chkumount" ]; then
			eval "$(/etc/hotplug/storage unplug $MOD_CGI_CMD)"
		fi
	fi
fi

if [ "$0" = "status.cgi" ]
then
	formact="/cgi-bin/status.cgi"
else
	formact="/cgi-bin/pkgstatus.cgi?pkg=mod&cgi=mod/mounted"
fi
	
sec_begin '$(lang de:"Eingeh&auml;ngte Partitionen" en:"Mounted partitions")'
dfout=$(df -h | sed -e '1d' | sed -n ':a;$!N;$!ba;s/\n  */ /g;p')
mfilt=$(mount|grep -E "^/dev/sd|^/dev/mapper/|^https://|^.* on .* type jffs|^.* on .* type fuse|^.* on .* type cifs|^.*:/.* on .* type nfs")
MPOINTS=$(echo "$mfilt" | cut -d" " -f3)
rwstatus=$(echo "$mfilt" | sed -e 's/.* \(\/[^ ]*\) [^(]*(.*r\([o,w]\).*/\1 \2/') 
if [ "$MPOINTS" ]; then
	echo '<table border="0" colspacing="0" colpadding="0" style="border-spacing:0pt; table-layout:fixed;">'
	for path in $MPOINTS; do
		dfrow=$(echo "$dfout" | grep -m 1 $path)
		device="$(echo $dfrow | awk '{print $1}')"
		total="$(echo $dfrow | awk '{print $2}' | sed -e 's/k/ K/;s/M/ M/;s/G/ G/')"
		used="$(echo $dfrow | awk '{print $3}' | sed -e 's/k/ K/;s/M/ M/;s/G/ G/')"
		free="$(echo $dfrow | awk '{print $4}' | sed -e 's/k/ K/;s/M/ M/;s/G/ G/')"
		percent="$(echo $dfrow | awk '{print $5}' | sed -e 's/[^0-9]//')"
		actstatus=$(echo "$rwstatus" | grep "$path" | sed -e "s/.* //")
		if [ "$actstatus" = "w" ]; then
			barstyle="rw"
			newstatus="r"
			rdisabled=''
			wdisabled='disabled="disabled" '
		else
			barstyle="ro"
			newstatus="w"
			rdisabled='disabled="disabled" '
			wdisabled=''
		fi
		echo -n '<tr><td class="path'$barstyle'"><b>'$path'</b></td><td class="bartdthpdg">'$device'</td>'
		echo '<th colspan="2" class="bartdth"><small>$(lang de:"Mountoptionen" en:"Mount options"):</small></td></tr>'
		echo -n '<tr><th colspan="2" class="bartdthpdg">'$used'B $(lang de:"von" en:"of") '$total'B $(lang de:"belegt" en:"used"), '$free'B $(lang de:"frei" en:"free")</th>'
		echo '<td nowrap="nowrap" class="bartdth" style="width:52px;">'
		echo '<form class="btn" action="'$formact'" method="post">'
		echo '<input type="hidden" name="cmd" value="-'$newstatus' '$path'">'
		echo '<input type="submit" value="R" '$rdisabled'class="rbtn'$barstyle'">'
		echo '<input type="submit" value="W" '$wdisabled'class="wbtn'$barstyle'">'
		echo '</form></td>'
		echo '<td class="bartdth" style="width:62px; text-align:right;">'
		echo '<form class="btn" action="'$formact'" method="post">'
		echo '<input type="hidden" name="cmd" value="'$path'">'
		echo '<input type="submit" value="unmount" style="width:60px;">'
		echo '</form></td>'
		echo '</tr><tr><th colspan="4" class="bartdth">'
		stat_bar $barstyle $percent
		echo '</th></tr>'
	done
	echo "</table>"
else
	echo "<br>$(lang de:"keine gefunden" en:"none found")<br>"
fi
sec_end
