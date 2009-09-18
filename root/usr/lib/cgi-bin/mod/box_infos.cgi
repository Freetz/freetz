#!/bin/sh

PATH=/mod/bin:/mod/usr/bin:/mod/sbin:/mod/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin

let _width=$_cgi_width-236
notdefined='$(lang de:"unbekannt" en:"unknown")'
divstyle="style='margin-top:6px;'"

if [ -r /var/env ]; then
	var_env=$(cat /var/env)
	loaderversion=$(echo "$var_env" | grep bootloaderVersion | sed -e "s/bootloaderVersion\t//")
	cpu_frequency=$(($(echo "$var_env" | grep cpufrequency | sed -e "s/cpufrequency\t//")/1000000))
	sys_frequency=$(($(echo "$var_env" | grep sysfrequency | sed -e "s/sysfrequency\t//")/1000000))
	ip_init_address=$(echo "$var_env" | grep my_ipaddress | sed -e "s/my_ipaddress\t//")
	mac_addresses=$(echo "$var_env" | grep -E "(^mac)" | sed -e "s/\(^mac[^\t]*\)\t\(.*\)/\1: \2/g")
	mac_lan=$(echo "$mac_addresses" | grep "maca" | sed -e 's/maca: //')
	mac_dsl=$(echo "$mac_addresses" | grep "macdsl" | sed -e 's/macdsl: //')
	mac_wlan=$(echo "$mac_addresses" | grep "macwlan" | sed -e 's/macwlan: //')
else
	var_env=""
	loaderversion=$notdefined
	cpu_frequency=$notdefined
	sys_frequency=$notdefined
	ip_init_address=$notdefined
	mac_lan=$notdefined
	mac_dsl=$notdefined
	mac_wlan=$notdefined
fi
if [ -r /proc/cpuinfo ]; then
	cpu_family="$(cat /proc/cpuinfo | grep 'system type'| sed -e 's/.*: //')"
	cpu_model="$(cat /proc/cpuinfo | grep 'cpu model'| sed -e 's/.*: //')"
else
	cpu_family=""
	cpu_model=""
fi
if [ -r /etc/version ]; then
	avm_date=$(cat /etc/version | grep "export FIRMWARE_DATE" | sed -e 's/export FIRMWARE_DATE\="\(.*\)"/\1/')
else
	avm_date=$notdefined
fi
if [ -r /etc/.revision ]; then
	avm_revision=$(cat /etc/.revision)
else
	avm_revision=$notdefined
fi

sec_begin '$(lang de:"Hardware-Informationen" en:"Informations about hardware"):'
 echo '<div '$divstyle'><b>$(lang de:"Boxname" en:"Box name"):</b> '$CONFIG_PRODUKT_NAME'&nbsp;&nbsp;&nbsp;<b>ANNEX:</b> '$CONFIG_ANNEX'</div>'
 echo -n "<div $divstyle><b>HWRevision:</b> $HWRevision.$(($HWRevision_ATA)).$((HWRevision_BitFileCount)).$(($HWRevision_Reserved1))&nbsp;&nbsp;&nbsp;"
 echo "<b>Flash(ROM):</b> $CONFIG_ROMSIZE MB&nbsp;&nbsp;&nbsp;<b>RAM:</b> $CONFIG_RAMSIZE MB</div>"
 echo "<div $divstyle>"
 if [ ! -z "$cpu_family" ]; then
	echo '<b>CPU$(lang de:"-Familie" en:" family"):</b> '$cpu_family'&nbsp;&nbsp;&nbsp;'
 fi
 if [ ! -z "$cpu_model" ]; then
	echo '<b>CPU$(lang de:"-Modell" en:" model"):</b> '$cpu_model
 fi
 echo "</div>"
 echo -n '<div '$divstyle'><b>$(lang de:"CPU-Frequenz" en:"CPU frequency"):</b> '$cpu_frequency' MHz&nbsp;&nbsp;&nbsp;'
 echo '<b>$(lang de:"Systemfrequenz" en:"System frequency"): </b> '$sys_frequency' MHz</div>'
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

sec_begin '$(lang de:"Firmware-Informationen" en:"Informations about firmware"):'
 echo -n '<div '$divstyle'><b>Firmware$(lang de:"" en:" ")version:</b> '$CONFIG_VERSION_MAJOR'.'$CONFIG_VERSION'&nbsp;&nbsp;'
 echo -n '<b>AVM-Revision:</b> '$avm_revision'&nbsp;&nbsp;&nbsp;'
 echo -n '<b>$(lang de:"Sprache" en:"Language"):</b> '$Language'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Erstellungsdatum" en:"Compilation date") (AVM):</b> '$avm_date'</div>'
 echo '<div '$divstyle'><b>$(lang de:"Bootloaderversion" en:"Version of bootloader"):</b> '$loaderversion'</div>'
sec_end

if [ -r /var/env.cache ]; then
	sec_begin '$(lang de:"Umgebungsvariablen" en:"Environment variables"):'
		echo -n '<textarea style="margin-top:6px; width: '$_width'px;" name="content" rows="5" cols="10" wrap="off" readonly>'
		cat /var/env.cache | sed -e "s/^export //g"
		echo -n '</textarea>'
	sec_end
fi
