#!/bin/sh

. /usr/lib/libmodcgi.sh


sec_begin "$(lang de:"Starttyp" en:"Start type")"

NMBD=$(which nmbd)
if [ -L "$NMBD" -o -x "$NMBD" ]; then
	smbd_label="$(lang de:"Dateifreigabe (smbd)" en:"Filesharing (smbd) "):&nbsp;"
else
	smbd_label=
fi

cgi_print_radiogroup_service_starttype \
	"enabled" "$SAMBA_ENABLED" "" "$smbd_label" 1

if [ -L "$NMBD" -o -x "$NMBD" ]; then
	cgi_print_radiogroup_service_starttype \
		"nmbd_enabled" "$SAMBA_NMBD_ENABLED" "" "$(lang de:"Namensaufl&ouml;sung (nmbd)" en:"Nameservices (nmbd) "):&nbsp;" 0
fi

sec_end


sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cgi_print_radiogroup \
	"smbd_security" "$SAMBA_SMBD_SECURITY" "" "$(lang de:"Samba security" en:"Samba security"):&nbsp;" \
	"share::$(lang de:"Share" en:"Share")" \
	"user::$(lang de:"User" en:"User")"

cgi_print_textline_p "user" "$SAMBA_USER" 40/255 "$(lang de:"Benutzername" en:"User name"):"
cgi_print_password_p "pass" "$SAMBA_PASS" 40/255 "$(lang de:"Passwort" en:"Password"):" \
	"<br><font size="-2">$(lang de:"leer lassen zum deaktivieren" en:"leave empty to deactivate")</font>"
cgi_print_textline_p "interfaces" "$SAMBA_INTERFACES" 40/255 "$(lang de:"IP-Adresse" en:"IP address"):" \
	"<br><font size="-2">$(lang de:"z.B.: 192.168.178.1/255.255.255.0 oder leer lassen f&uuml;r alle" en:"For example: 192.168.178.1/255.255.255.0 or leave blank for all")</font>"
cgi_print_textline_p "netbios_name" "$SAMBA_NETBIOS_NAME" 20/255 "$(lang de:"Netbios Name" en:"Netbios Name"):"
cgi_print_textline_p "workgroup" "$SAMBA_WORKGROUP" 20/255 "$(lang de:"Arbeitsgruppe" en:"Workgroup"):"
cgi_print_textline_p "server_string" "$SAMBA_SERVER_STRING" 40/255 "$(lang de:"Beschreibung" en:"Description"):"
cgi_print_textline_p "os_level" "$SAMBA_OS_LEVEL" 5 "$(lang de:"OS Level f&uuml;r Election" en:"OS level election"):"

cgi_print_checkbox_p "master" "$SAMBA_MASTER" "$(lang de:"Bevorzugter Master" en:"Preferred Master")"

sec_end


if [ -d /var/media/ftp ]; then
sec_begin "$(lang de:"Standardfreigaben" en:"Default shares")"
cgi_print_checkbox_p "avmshares" "$SAMBA_AVMSHARES" "$(lang de:"Alle Partitionen freigeben" en:"Share all partitions")"
cgi_print_checkbox_p "readonly" "$SAMBA_READONLY" "$(lang de:"Freigaben sind nur lesbar" en:"Shares are only readable")"
sec_end
fi

