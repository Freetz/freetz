#!/bin/sh

eval "$(modcgi branding:pkg:cmd mod_cgi)"
errpath=""
if [ ! -z "$MOD_CGI_CMD" ]; then
	chkremount=$(echo "$MOD_CGI_CMD" | sed -n -e "s/^-[r,w].*/ok/p")
	chkumount=$(echo "$MOD_CGI_CMD" | sed -n -e "s/^\/.*/ok/p")
	if [ ! -z "$chkremount" ]; then
		mount -o remount $MOD_CGI_CMD 2>/tmp/mounted.err
	else
		if [ ! -z "$chkumount" ]; then
			sec_begin '$(lang de:"Unmount-Meldungen" en:"Unmount messages")'
			/etc/hotplug/storage unplug $MOD_CGI_CMD 2>/tmp/mounted.err | sed -e 's/\(.*\)/<div style=\"font-family\:monospace\; font-size\:8pt\;\">\1<\/div>/g'
			sec_end
		fi
	fi
	if [ -r /tmp/mounted.err ]
	then
		errpath=$(echo "$MOD_CGI_CMD" | sed -e "s/.* //g")
	fi
fi

if [ "$0" = "pkgstatus.cgi" ]
then
	formact="/cgi-bin/pkgstatus.cgi?pkg=mod&cgi=mod/mounted"
else
	formact="/cgi-bin/status.cgi"
fi
	
sec_begin '$(lang de:"Eingeh&auml;ngte Partitionen" en:"Mounted partitions")'
disabledbtn='disabled="disabled" '
dfout=$(df -h | sed -e '1d' | sed -n ':a;$!N;$!ba;s/\n  */ /g;p')
mfilt=$(mount|grep -E "^/dev/sd|^/dev/mapper/|^https://|^http://|^.* on .* type jffs|^.* on .* type fuse|^.* on .* type cifs|^.*:/.* on .* type nfs")
if [ ! -z "$mfilt" ]
then
	echo '<table border="0" colspacing="0" colpadding="0" style="border-spacing:0px; table-layout:fixed; padding-right:5px;">'
	echo "$mfilt" | while read -r device null1 path null2 fstyp mountopts
	do
		echo "$dfout" | grep -m 1 $path | sed -e "s/\(% [^ ]*\) /\1\n/g" | while read -r device total used free percent path
		do
			if [ "$fstyp"="fuse" ]
			then
				if [ $(echo "$device" | grep "http") ]
				then
					fstyp="davfs"
				fi
			else
				if [ "$fstyp"="fuseblk" ]
				then
					fstyp="ntfs"
				fi
			fi
			total=$(echo $total | sed -e 's/k/ K/;s/M/ M/;s/G/ G/')
			used=$(echo $used | sed -e 's/k/ K/;s/M/ M/;s/G/ G/')
			free=$(echo $free | sed -e 's/k/ K/;s/M/ M/;s/G/ G/')
			percent=$(echo $percent | sed -e 's/[^0-9]//')
			actstatus=$(echo "$mountopts" | sed -e 's/(r\([o,w]\).*/\1/')
			showpath=$(echo $path | sed -e 's/\//\/\&shy;/g')
			showdev=$(echo $device | sed -e 's/\//\/\&shy;/g')
			rdisabled=$disabledbtn
			wdisabled=$disabledbtn
			if [ "$actstatus" = "w" ]
			then
				barstyle="rw"
				newstatus="r"
				[ "$MOD_MOUNTED_UMOUNT" = "yes" ] && rdisabled=''
			else
				barstyle="ro"
				newstatus="w"
				[ "$MOD_MOUNTED_UMOUNT" = "yes" ] && wdisabled=''
			fi
			echo -n '<tr><td class="path'$barstyle'"><b>'$showpath'</b></td><td class="bartdthpdg">'$showdev'</td>'
			echo -n '<td class="bartdth"><b>'$fstyp'</b></td>'
			echo -n '<td class="bartdth">'
			if [ "$security" -eq "0" ]
			then
				echo -n '<small>$(lang de:"Mountoptionen" en:"Mount options"):</small>'
			fi
			echo '</td></tr>'
			echo -n '<tr><th colspan="2" class="bartdthpdg">'$used'B $(lang de:"von" en:"of") '$total'B $(lang de:"belegt" en:"used"), '$free'B $(lang de:"frei" en:"free")</th>'
			echo '<th colspan="2" nowrap="nowrap" class="bartdth" style="text-align:right; padding-right:3px;">'
			echo '<form class="btn" action="'$formact'" method="post" style="display:inline;">'
			echo '<input type="hidden" name="cmd" value="-'$newstatus' '$path'">'
			echo '<input type="submit" value="R" '$rdisabled'class="rbtn'$barstyle'">'
			echo '<input type="submit" value="W" '$wdisabled'class="wbtn'$barstyle'">'
			echo '</form>'
			if [ "$MOD_MOUNTED_UMOUNT" = "yes" ]
			then
				echo '<form class="btn" action="'$formact'" method="post" style="display:inline;">'
				echo '<input type="hidden" name="cmd" value="'$path'">'
				echo '<input type="submit" value="unmount" style="width:60px; padding:1px;">'
				echo '</form>'
			fi
			echo '</th></tr>'
			if [ -r /tmp/mounted.err ]
			then
				if [ "$errpath" = "$path" ]
				then
					echo '<tr><th colspan="4" class="bartdth" style="font-family:monospace; font-size:8pt; color:#ff0000; text-decoration: blink;"><b>'
					cat /tmp/mounted.err | sed -e "s/\(.*\)/\1<br>/g"
					echo '</b></th></tr>'
				fi
			fi
			echo '<tr><th colspan="4" class="bartdth" style="vertical-align: top;">'
			stat_bar $barstyle $percent
			echo '</th></tr>'
			echo '<tr style="height:15px;"><td></td><td></td><td></td><td></td></tr>'
		done
	done
	echo "</table>"
else
	echo "<br>$(lang de:"keine gefunden" en:"none found")<br>"
fi
sec_end
rm -f /tmp/mounted.err
