#!/bin/sh


. /usr/lib/libmodcgi.sh

# radio group dis-/enable
check "$USBROOT_ENABLED" yes:e1 "*":e2
# current state
if [ "$(/mod/etc/init.d/rc.usbroot status)" == "running" ]; then
	cur_state="$(lang de:"Aktiviert" en:"Active")"
else
	cur_state="$(lang de:"Inaktiv" en:"Inactive")"
fi
# radio group unmound old root
check "$USBROOT_UNMOUNTOLDROOT" yes:y1 "*":n1

# check if build into kernel or if modules are available
for i in ext2 ext3; do
	if grep -q "$i" /proc/filesystems || [ -f "/lib/modules/$(uname -r)/kernel/fs/$i/$i.ko" ]; then
		eval $i=y
	else
		eval $i=n
	fi
done

# html output
sec_begin "$(lang de:"USB Root aktivieren/deaktivieren" en:"Enable/Disable USB root")"

cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$e1_chk/><label
for="e1"> $(lang de:"Aktiviert" en:"Activated")</label><input id="e2" type="radio"
name="enabled" value="no"$e2_chk/><label for="e2"> $(lang de:"Deaktiviert" en:"Deactivated")</label>
<span style="margin-left: 60px"><strong>$(lang de:"Aktueller Status:" en:"Current state:")</strong> $cur_state</span></p>
EOF

sec_end

sec_begin "$(lang de:"Ger&auml;t- und Partitionswahl" en:"Device and partition selection")"

cat << EOF
<table width="100%">
  <tr>
    <th style="border-bottom: 1px solid black">&nbsp;</th>
    <th style="border-bottom: 1px solid black">$(lang de:"Ger&auml;t" en:"Device")</th>
    <th style="border-bottom: 1px solid black">$(lang de:"Partition" en:"Partition")</th>
    <th style="border-bottom: 1px solid black">$(lang de:"Gr&ouml;&szlig;e" en:"Size")</th>
    <th style="border-bottom: 1px solid black">$(lang de:"Dateisystem" en:"Filesystem")</th>
  </tr>
EOF

i=1

awk '/^   8 +.*sd[a-z][0-9]?/ { print $4, int($3/1024) }' /proc/partitions | while read DEVPART SIZE; do
	# filter partition number, get vendor and model string from sysfs, guess filesystem type
	dev=$(echo $DEVPART | sed 's/[0-9]//g')
	vendor=$(cat /sys/block/$dev/device/vendor)
	model=$(cat /sys/block/$dev/device/model)
	fs=$([ -x /usr/bin/fstyp ] && fstyp "/dev/$DEVPART" || echo "$(lang de:"unbekannt" en:"unknown")")
	mountastyp=$fs
	html_devpart=$(html "$DEVPART")

	# set radio button states
	checked=''; disabled=''
	if [ "$USBROOT_DEVICE" == "/dev/$DEVPART" ]; then
		checked=' checked="checked"'
		mediafs=$fs
	fi
	# only allow filesystems with kernel module support
	[ "$(eval echo \$$fs)" != 'y' ] && disabled=' disabled="disabled"'
	# but allow ext3 to be mounted as ext2
	[ "$fs:$ext2:$ext3" == 'ext3:y:n' ] && { disabled=''; mountastyp='ext2'; }

	cat << EOF
  <tr>
    <td><input id="rb$i" type="radio" name="device"
      onchange="document.forms[0].elements['fstype'].value = '$mountastyp';"
      value="/dev/$html_devpart"$checked$disabled/></td>
    <td><label for="rb$i">$(html "$vendor") $(html "$model")</label></td>
    <td><label for="rb$i">/dev/$html_devpart</label></td>
    <td align="right">$(html "$SIZE") MiB</td>
    <td style="padding-left: 0.7em;">$(html "$fs")</td>
  </tr>
EOF

	let i++
done

cat << EOF
</table>
<p><small>$(lang \
  de:"Hinweis: Es k&ouml;nnen nur Partitionen mit Dateisystemtyp <i>ext2</i> oder <i>ext3</i> ausgew&auml;hlt werden. Au&szlig;erdem muss das jeweilige Kernelmodul vorhanden sein. Eine Ausnahme bildet <i>ext3</i>, welches ggf. als <i>ext2</i> (ohne Journaling-Funktionalit&auml;t) gemountet werden kann. Dazu muss der Wert von &bdquo;Dateisystem mounten als&rdquo; entsprechend gesetzt sein." \
  en:"Hint: Only partitions of typ <i>ext2</i> or <i>ext3</i> are selectable. Also the corresponding kernel module has to be available. An exception is <i>ext3</i> with can be mounted as <i>ext2</i> (without the journaling functionality). Check setting 'Mount filesystem as' below ." \
)</small></p>
EOF

sec_end

sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cat << EOF
<p>$(lang de:"Root-Verzeichnis" en:"Root directory"): <input id="usbpath"
size="40" maxlength="64" type="text" name="usbpath" value="$(html "$USBROOT_USBPATH")"/><br />
<small>$(lang \
  de:"Geben Sie hier den vollen Ordnernamen innerhalb der Ordner-Hierarchie des USB-Ger&auml;tes an, welcher als Root-Verzeichnis verwendet werden soll, z.B. /mein/avmroot. Der Ordnername darf keine Leerzeichen enthalten." \
  en:"Enter the full path name of the directory which should be used as root directory, e.g. /my/avmroot. The name must not contain blanks." \
)</small></p>
<p><label for="fstype">$(lang de:"Dateisystem mounten als" en:"Mount filesystem as"): </label><input
type="input" id="fstype" size="20" maxlength="10" name="fstype" value="$(html "$USBROOT_FSTYPE")"/></p>
<p>$(lang de:"Mount Optionen" en:"Mount options"): <input id="mntoptions"
size="40" maxlength="64" type="text" name="mntoptions" value="$(html "$USBROOT_MNTOPTIONS")"/><br />
<small>$(lang \
  de:"Geben Sie hier kommagetrennte Optionen an, welche beim Mounten des Dateisystems verwendet werden (siehe Man-Pages von mount). Beispiel: rw,noatime,nodiratime" \
  en:"Enter a comma-separated list of options which are used when the filesystem is mounted. E.g.: rw,noatime,nodiratime" \
)</small></p>
<p>$(lang de:"Altes Root-Filesystem (Flashspeicher) unmounten:" en:"Unmount old root filesystem (flash memory):") 
<input id="y1" type="radio" name="unmountoldroot" value="yes"$y1_chk><label for="y1"> 
$(lang de:"Ja" en:"Yes")</label><input id="n1" type="radio" name="unmountoldroot" value="no"$n1_chk/><label for="n1"> $(lang de:"Nein" en:"No")</label><br />
<small>$(lang de:"Achtung: Das Aktivieren dieser Option kann zu einer Reboot-Schleife f&uuml;hren." en:"Caution: Activating this option can cause reboot loops")</small></p>
EOF

sec_end

cat << EOF
<p>$(lang \
  de:"&Auml;nderungen werden erst nach einem Neustart aktiv, auch wenn hier bereits die neuen Werte angezeigt werden." \
  en:"Changes will take effect after a reboot, even if new settings will already be displayed here." \
)</p>
EOF

