#!/bin/sh

PATH=/mod/bin:/mod/usr/bin:/mod/sbin:/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin
. /etc/freetz_info.cfg

let _width=$_cgi_width-230

sec_begin '$(lang de:"Firmware-Informationen" en:"Informations about firmware")'
 echo "<p><b>$(lang de:"Boxtyp:" en:"Box type:")</b> $FREETZ_INFO_BOXTYPE&nbsp;&nbsp;<b>$(lang de:"AVM Firmwareversion:" en:"AVM Firmware version:")</b> $FREETZ_INFO_FIRMWAREVERSION&nbsp;&nbsp;<b>$(lang de:"Sprache:" en:"Language:")</b> $FREETZ_INFO_LANG</p>"
 echo "<p><b>$(lang de:"FREETZ-Version:" en:"FREETZ version:")</b> $FREETZ_INFO_SUBVERSION</p>"
date_de_format=$(echo "$FREETZ_INFO_MAKEDATE" \
		| sed -e 's/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)\-\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)\(.*\)/\3.\2.\1 \4\:\5\:\6/')
 echo "<p><b>$(lang de:"Erstellungsdatum:" en:"Making date:")</b> $date_de_format</p>"
 echo "<p><b>$(lang de:"Urspr&uuml;nglicher Dateiname:" en:"Initial file name:")</b><br>$FREETZ_INFO_IMAGE_NAME</p>"
 echo "<p><b>$(lang de:"Benutzerdefinierte Informationen:" en:"User defined informations:")</b><br>$FREETZ_INFO_COMMENT</p>"
sec_end

if [ -r /etc/.config ]; then
	_dot_config=$(cat /etc/.config | sed -e "s/\=y/\<br\>/g;s/FREETZ_//g")
	_patches=$(echo "$_dot_config" | grep -E "(PATCH_|USBSTORAGE_|AUTOMOUNT_|AUTORUN_)" \
	| sed -e "s/USBSTORAGE_//g;s/PATCH_//g")
	_removes=$(echo "$_dot_config" | grep "REMOVE_" | sed -e "s/REMOVE_//g")
	_libs=$(echo "$_dot_config" | grep "LIB_" | sed -e "/EXTERNAL/d" | sed -e "s/LIB_//g")
	_modules=$(echo "$_dot_config" | grep "MODULE_" | sed -e "s/MODULE_//g")
	_packages=$(echo "$_dot_config" | grep "PACKAGE_" | sed -e "/EXTERNAL/d" | sed -e "s/PACKAGE_//g;/_/d")
	sec_begin '$(lang de:"FREETZ-Konfiguration:" en:"FREETZ configuration:")'
		echo -n '<table style="border-spacing:3pt;"><tr>'
		echo -n '<td><b>$(lang de:"Patches:" en:"Patches:")</b></td>'
		echo -n '<td><b>$(lang de:"Libraries:" en:"Libraries:")</b></td>'
		echo -n '<td><b>$(lang de:"Module:" en:"Modules:")</b></td>'
		echo -n '<td><b>$(lang de:"Pakete:" en:"Packages:")</b></td></tr>'
		echo -n '<tr><td style="vertical-align:top; text-align: left; text-transform: lowercase; font-weight: normal;">'
		echo -n $_patches
		echo -n '</td><th rowspan="3" style="vertical-align:top; text-align: left; font-weight: normal;">'
		echo -n $_libs
		echo -n '</th><th rowspan="3" style="vertical-align:top; text-align: left; text-transform: lowercase; font-weight: normal;">'
		echo -n $_modules
		echo -n '</th><th rowspan="3" style="vertical-align:top; text-align: left; text-transform: lowercase; font-weight: normal;">'
		echo -n $_packages
		echo -n '</th></tr>'
		echo -n '<tr><td><b>$(lang de:"Entfernt:" en:"Removes:")</b></td></tr>'
		echo -n '<tr><td style="vertical-align:top; text-align: left; text-transform: lowercase; font-weight: normal;">'
		echo -n $_removes
		echo -n '</td></tr></table>'
		echo -n '<div><a href="/cgi-bin/extras.cgi/mod/do_download_config"><b>.config:</b></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/cgi-bin/extras.cgi/mod/do_download_config">$(lang de:"Herunterladen als Textdatei" en:"Download as text file")</a></div>'
		echo -n '<textarea style="width: '$_width'px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		html < /etc/.config
		echo -n '</textarea>'
	sec_end
fi

if [ ! -z "$FREETZ_INFO_EXTERNAL_FILES" ]; then
	sec_begin '$(lang de:"Ausgelagerte (externalisierte) Dateien:" en:"Externalised files:")'
		echo -n '<textarea style="width: '$_width'px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		echo -n "$FREETZ_INFO_EXTERNAL_FILES"
		echo -n '</textarea>'
	sec_end
fi




