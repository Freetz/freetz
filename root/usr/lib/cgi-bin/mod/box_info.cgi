#!/bin/sh

PATH=/mod/bin:/mod/usr/bin:/mod/sbin:/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin

# include environment variables
[ -r /var/env.cache ] && . /var/env.cache

let _width=$_cgi_width-236
notdefined='$(lang de:"unbekannt" en:"unknown")'
divstyle="style='margin-top:6px;'"

if [ -r /var/env ]; then
	while read -r key value; do
		case $key in
			bootloaderVersion) loaderversion=$value ;;
			cpufrequency)	let cpu_frequency=value/1000000 ;;	
			sysfrequency)	let sys_frequency=value/1000000 ;;
			my_ipaddress)	ip_init_address=$value ;;
			maca)		mac_lan=$value ;;
			macdsl)		mac_dsl=$value ;;
			macwlan)	mac_wlan=$value ;;
		esac
	done < /var/env
else
	loaderversion=$notdefined
	cpu_frequency=$notdefined
	sys_frequency=$notdefined
	ip_init_address=$notdefined
	mac_lan=$notdefined
	mac_dsl=$notdefined
	mac_wlan=$notdefined
fi
if [ -r /proc/cpuinfo ]; then
	cpu_family="$(sed -ne '/system type/ s/.*: //p' /proc/cpuinfo)"
	cpu_model="$(sed -ne '/cpu model/ s/.*: //p' /proc/cpuinfo)"
else
	cpu_family=""
	cpu_model=""
fi
if [ -r /etc/version ]; then
	avm_date=$(sed -ne 's/^export FIRMWARE_DATE\="\(.*\)"/\1/p' /etc/version)
else
	avm_date=$notdefined
fi
if [ -r /etc/.revision ]; then
	avm_revision=$(cat /etc/.revision)
else
	avm_revision=$notdefined
fi
if [ -r /proc/sys/urlader/environment ]; then
	flash_size=$(($(sed -ne "s/^flashsize.\([0-9x].*\)/\1/p" /proc/sys/urlader/environment) / 0x100000))
else
	flash_size=$CONFIG_ROMSIZE
fi
if [ -x $(which run_clock) ]; then
	run_clock=$(run_clock | sed 's/.*: //')
fi

sec_begin '$(lang de:"Hardware-Informationen" en:"Information about hardware"):'
 echo '<div '$divstyle'><b>$(lang de:"Boxname" en:"Box name"):</b> '$CONFIG_PRODUKT_NAME'&nbsp;&nbsp;&nbsp;<b>ANNEX:</b> '$CONFIG_ANNEX'</div>'
 echo -n "<div $divstyle><b>HWRevision:</b> $HWRevision.$(($HWRevision_ATA)).$((HWRevision_BitFileCount)).$(($HWRevision_Reserved1))&nbsp;&nbsp;&nbsp;"
 echo "<b>Flash(ROM):</b> $flash_size MB&nbsp;&nbsp;&nbsp;<b>RAM:</b> $CONFIG_RAMSIZE MB</div>"
 echo "<div $divstyle>"
 if [ ! -z "$cpu_family" ]; then
	echo '<b>CPU$(lang de:"-Familie" en:" family"):</b> '$cpu_family'&nbsp;&nbsp;&nbsp;'
 fi
 if [ ! -z "$cpu_model" ]; then
	echo '<b>CPU$(lang de:"-Modell" en:" model"):</b> '$cpu_model
 fi
 echo "</div>"
 echo -n '<div '$divstyle'><b>$(lang de:"CPU-Frequenz" en:"CPU frequency"):</b> '$cpu_frequency' MHz&nbsp;&nbsp;&nbsp;'
 echo '<b>$(lang de:"Systemfrequenz" en:"System frequency"):</b> '$sys_frequency' MHz</div>'
 echo '<div '$divstyle'><b>$(lang de:"Betriebsstundenz&auml;hler" en:"Operating hours counter"):</b> '$run_clock'</div>'
sec_end

sec_begin '$(lang de:"Netzwerk" en:"Network"):'
 host_name="$(hostname)"
 act_ip="$(hostname -i)"
 echo '<div '$divstyle'><b>$(lang de:"Aktuelle IP-Adresse" en:"Current IP address"):</b> '$act_ip'&nbsp;&nbsp;&nbsp;<b>Hostname:</b> '$host_name'</div>'
 echo '<div '$divstyle'><b>Urloader IP$(lang de:"-Adresse" en:" address"):</b> '$ip_init_address'<br></div>'
 echo '<div '$divstyle'><b>MAC$(lang de:"-Adressen" en:" address"):</b><br>'
 echo '<b>DSL:</b> <small>'$mac_dsl'</small>&nbsp;&nbsp;&nbsp;<b>LAN:</b> <small>'$mac_lan'</small>&nbsp;&nbsp;&nbsp;<b>WLAN:</b> <small>'$mac_wlan'</small></div>'
sec_end

if [ -r /proc/avalanche/avsar_ver ]; then
	dsl_infos="$(cat /proc/avalanche/avsar_ver)"
	sec_begin '$(lang de:"DSL-Treiber und Hardware" en:"DSL drivers and hardware"):'
 		echo "<pre>$dsl_infos</pre>"
	sec_end
fi

sec_begin '$(lang de:"Firmware-Informationen" en:"Information about firmware"):'
 echo -n '<div '$divstyle'><b>Firmware$(lang de:"" en:" ")version:</b> '$CONFIG_VERSION_MAJOR'.'$CONFIG_VERSION'&nbsp;&nbsp;'
 echo -n '<b>AVM-Revision:</b> '$avm_revision'&nbsp;&nbsp;&nbsp;'
 echo -n '<b>$(lang de:"Sprache" en:"Language"):</b> '$Language'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Erstellungsdatum" en:"Compilation date") (AVM):</b> '$avm_date'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Bootloaderversion" en:"Version of bootloader"):</b> '$loaderversion'</div>'
sec_end

if [ -r /var/env.cache ]; then
	sec_begin '$(lang de:"Umgebungsvariablen" en:"Environment variables"):'
		echo -n '<textarea style="margin-top:6px; width: '$_width'px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		sed -e "s/^export //g" /var/env.cache | html
		echo -n '</textarea>'
	sec_end
fi
