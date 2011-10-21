#!/bin/sh


. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Starttyp" en:"Start type")'

NMBD=$(which nmbd)
if [ -L "$NMBD" -o -x "$NMBD" ]; then
	smbd_label="$(lang de:"Dateifreigabe (smbd)" en:"Filesharing (smbd) "):&nbsp;"
else
	smbd_label=
fi

cgi_print_radiogroup_service_starttype \
	"smbd_enabled" "$SAMBA_ENABLED" "" "$smbd_label" 1

if [ -L "$NMBD" -o -x "$NMBD" ]; then
	cgi_print_radiogroup_service_starttype \
		"nmbd_enabled" "$SAMBA_NMBD_ENABLED" "" "$(lang de:"Namensaufl&ouml;sung (nmbd)" en:"Nameservices (nmbd) "):&nbsp;" 0
fi

sec_end

if [ -d /var/media/ftp ]; then
sec_begin '$(lang de:"Einstellungen" en:"Settings")'

. /etc/default.samba/modlibsamba
if [ "$MODLIBSAMBA_ENABLED" == "yes" ]; then
	SAMBACONF_ENABLED="$(lang de:"an" en:"on")"
else
	SAMBACONF_ENABLED="$(lang de:"aus" en:"off")"
fi
if [ "$MODLIBSAMBA_PASSWORD" == "\"\"" ]; then
	SAMBACONF_PASSWORD="$(lang de:"ohne" en:"without")"
else
	SAMBACONF_PASSWORD="$(lang de:"gesetzt" en:"set")"
fi
if [ "$MODLIBSAMBA_READONLY" == "yes" ]; then
	SAMBACONF_READONLY="$(lang de:"lesen" en:"read")"
else
	SAMBACONF_READONLY="$(lang de:"schreiben" en:"write")"
fi

cat << EOF
<p>
$(lang de:"Standard Freigabe(n) bitte im AVM WebIF festlegen" en:"Standard share(s), please specify in AVM WebIF"):
<ul>
<li>$(lang de:"vor Firmware 04.86: Einstellungen > USB-Ger&auml;te > USB-Speicher" en:"before firmware 04.86: Preferences > USB devices > USB memory")</li>
<li>$(lang de:"seit Firmware 04.86: Heimnetz > Speicher (NAS) > Sicherheit" en:"since firmware 04.86: Homenet > Storage (NAS) > Security")</li>
</ul>
$(lang de:"Optionen" en:"Options"):
<ul>
<li>$(lang de:"Netzwerkspeicher/NAS (an/aus, momentan" en:"NAS/network-storage (on/off, currently") $SAMBACONF_ENABLED)</li>
<li>$(lang de:"Zugriffsberechtigung Heimnetz (lesen/schreiben, momentan" en:"Access Authorization local lan (read/write, currently") $SAMBACONF_READONLY)</li>
<li>$(lang de:"Kennwortschutz (ohne/setzen, momentan" en:"Password protection (without/set, currently") $SAMBACONF_PASSWORD)</li>
</ul>
</p>
EOF

sec_end
fi

sec_begin '$(lang de:"Samba" en:"Samba")'

cgi_print_radiogroup \
	"smbd_security" "$SAMBA_SMBD_SECURITY" "" "$(lang de:"Samba security" en:"Samba security"):&nbsp;" \
	"share::$(lang de:"Share" en:"Share")" \
	"user::$(lang de:"User" en:"User")"

cgi_print_textline_p "user" "$SAMBA_USER" 40/255 "$(lang de:"Benutzername" en:"User name"):"
cgi_print_textline_p "interfaces" "$SAMBA_INTERFACES" 40/255 "$(lang de:"IP-Adresse" en:"IP address"):" \
	"<br><font size="-2">$(lang de:"z.B.: 192.168.178.1/255.255.255.0 oder leer lassen f&uuml;r alle" en:"For example: 192.168.178.1/255.255.255.0 or leave blank for all")</font>"
cgi_print_textline_p "netbios_name" "$SAMBA_NETBIOS_NAME" 20/255 "$(lang de:"Netbios Name" en:"Netbios Name"):"
cgi_print_textline_p "workgroup" "$SAMBA_WORKGROUP" 20/255 "$(lang de:"Arbeitsgruppe" en:"Workgroup"):"
cgi_print_textline_p "server_string" "$SAMBA_SERVER_STRING" 40/255 "$(lang de:"Beschreibung" en:"Description"):"
cgi_print_textline_p "os_level" "$SAMBA_OS_LEVEL" 5 "$(lang de:"OS Level f&uuml;r Election" en:"OS level election"):"

cgi_print_checkbox_p "master" "$SAMBA_MASTER" "$(lang de:"Bevorzugter Master" en:"Preferred Master")"

sec_end
