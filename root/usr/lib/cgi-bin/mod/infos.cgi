#!/bin/sh

PATH=/mod/bin:/mod/usr/bin:/mod/sbin:/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin
. /etc/freetz_info.cfg

let _width=$_cgi_width-236
divstyle="style='margin-top:6px;'"

sec_begin '$(lang de:"Firmware-Informationen" en:"Information about firmware"):'
 echo -n '<div '$divstyle'><b>$(lang de:"Boxtyp" en:"Box type"):</b> '$FREETZ_INFO_BOXTYPE'&nbsp;&nbsp;'
 echo -n '<b>$(lang de:"AVM Firmwareversion:" en:"AVM firmware version:")</b> '$FREETZ_INFO_FIRMWAREVERSION'&nbsp;&nbsp;'
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
		| sed -e 's/\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)\-\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)\(.*\)/\3.\2.\1 \4\:\5\:\6/')
 echo '<div '$divstyle'><b>$(lang de:"Erstellungsdatum" en:"Creation date"):</b> '$date_de_format'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Urspr&uuml;nglicher Dateiname" en:"Initial file name"):</b><br>'$FREETZ_INFO_IMAGE_NAME'</div>'
 if [ ! -z "$FREETZ_INFO_COMMENT" ]; then
	echo '<div '$divstyle'><b>$(lang de:"Benutzerdefinierte Informationen" en:"User defined information"):</b><br>'
	echo "$FREETZ_INFO_COMMENT</div>"
 fi
sec_end

if [ -r /etc/.config ]; then
	_dot_config=$(cat /etc/.config | sed -e "s/\=y/\<br\>/g;s/FREETZ_//g" | sort)
	_patches=$(echo "$_dot_config" | grep -E "(PATCH_|USBSTORAGE_|AUTOMOUNT_|AUTORUN_)" \
	| sed -e "s/USBSTORAGE_//g;s/PATCH_//g" | sort | sed -e "s/AUTOMOUNT_\(.*\)/\<small\>\> \1\<\/small>/g")
	_removes=$(echo "$_dot_config" | grep "REMOVE_" | sed -e "s/REMOVE_//g")
	_libs=$(echo "$_dot_config" | grep "LIB_" | sed -e "/EXTERNAL/d" | sed -e "s/LIB_//g")
	_modules=$(echo "$_dot_config" | grep "MODULE_" | sed -e "s/MODULE_//g")
	_packages=$(echo "$_dot_config" | grep "PACKAGE_" | sed -e "/EXTERNAL/d" \
	| sed -e "s/PACKAGE_//g;s/AVM_FIREWALL/AVM-FIREWALL/g;s/INADYN_MT/INADYN-MT/g;/_CGI/d;s/\([^_]*\)\(_\)\(.*\)/\<small\>\> \3\<\/small>/g")
	_cgis=$(echo "$_dot_config" | grep -E "(PACKAGE_.*_CGI)" | sed -e "/EXTERNAL/d" | sed -e "s/PACKAGE_//g;s/_CGI//g;/_/d")
	_td_th_style='vertical-align:top; text-align: left; font-weight: normal; padding-right:10px;'
	_lowercase=' text-transform: lowercase;'
	_td='<td style="'$_td_th_style'">'
	_td_lowercase='<td style="'$_td_th_style$_lowercase'">'
	_th3_lowercase='<th rowspan="3" style="'$_td_th_style$_lowercase'">'
	_th3='<th rowspan="3" style="'$_td_th_style'">'
	sec_begin '$(lang de:"FREETZ-Konfiguration" en:"FREETZ configuration"):'
		echo '<table border="0" style="border-spacing:0pt;"><tr>'
		echo -n '<td><b>$(lang de:"Patches" en:"Patches"):</b></td>'
		echo -n '<td><b>$(lang de:"Pakete" en:"Packages"):</b></td>'
		echo -n '<td><b>$(lang de:"Module" en:"Modules"):</b></td>'
		echo '<td><b>$(lang de:"Libraries" en:"Libraries"):</b></td></tr>'
		echo -n '<tr>'$_td_lowercase
		echo -n $_patches
		echo -n '</td>'$_th3_lowercase
		echo -n $_packages
		echo -n '</th>'$_td
		echo -n $_modules
		echo -n '</td>'$_th3
		echo -n $_libs
		echo '</th></tr>'
		echo '<tr><td><b>$(lang de:"Entfernt" en:"Removes"):</b></td><td><b>$(lang de:"CGI-Pakete" en:"CGI Packages"):</b></td></tr>'
		echo -n '<tr>'$_td_lowercase
		echo -n $_removes
		echo -n '</td>'$_td_lowercase
		echo -n $_cgis
		echo '</td></tr></table>'
		echo '<div $divstyle><br><a href="/cgi-bin/extras.cgi/mod/do_download_config"><b>.config:</b></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/cgi-bin/extras.cgi/mod/do_download_config">$(lang de:"Herunterladen als Textdatei" en:"Download as text file")</a></div>'
		echo -n '<textarea style="width: '$_width'px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		html < /etc/.config
		echo '</textarea>'
	sec_end
fi

if [ ! -z "$FREETZ_INFO_EXTERNAL_FILES" ]; then
	sec_begin '$(lang de:"Ausgelagerte Dateien:" en:"Externalised files:")'
		echo -n '<textarea style="width: '$_width'px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		echo -n "$FREETZ_INFO_EXTERNAL_FILES"
		echo '</textarea>'
	sec_end
fi
