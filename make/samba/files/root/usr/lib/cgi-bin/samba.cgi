#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$SAMBA_MASTER" yes:master

sec_begin '$(lang de:"Starttyp" en:"Start type")'

NMBD=$(which nmbd)
if [ -L "$NMBD" -o -x "$NMBD" ]; then
	smbd_label="$(lang de:"Dateifreigabe (smbd)" en:"Filesharing (smbd) "):&nbsp;"
else
	smbd_label=
fi
if [ -e /mod/etc/default.inetd/inetd.cfg ]; then
	opt_inetd="inetd::$(lang de:"Inetd" en:"Inetd")"
else
	opt_inetd=
fi

cgi_print_radiogroup \
	"smbd_enabled" "$SAMBA_ENABLED" "$smbd_label" \
	"yes::$(lang de:"Automatisch" en:"Automatic")" \
	"no::$(lang de:"Manuell" en:"Manual")" \
	$opt_inetd

if [ -L "$NMBD" -o -x "$NMBD" ]; then
	cgi_print_radiogroup \
	"nmbd_enabled" "$SAMBA_NMBD_ENABLED" "$(lang de:"Namensaufl&ouml;sung (nmbd)" en:"Nameservices (nmbd) "):&nbsp;" \
	"yes::$(lang de:"Automatisch" en:"Automatic")" \
	"no::$(lang de:"Manuell" en:"Manual")"
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
	"smbd_security" "$SAMBA_SMBD_SECURITY" "$(lang de:"Samba security" en:"Samba security"):&nbsp;" \
	"share::$(lang de:"Share" en:"Share")" \
	"user::$(lang de:"User" en:"User")"

cat << EOF
<p><label for="s1">$(lang de:"Benutzername" en:"User name"):</label>
<input id="s1" type="text" name="user" size="40" maxlength="255" value="$(html "$SAMBA_USER")"></p>
<p>$(lang de:"IP-Adresse" en:"IP address"):
<input type="text" name="interfaces" size="40" maxlength="255" value="$(html "$SAMBA_INTERFACES")"><br>
<font size="-2">$(lang de:"z.B.: 192.168.178.1/255.255.255.0 oder leer lassen f&uuml;r alle" en:"For example: 192.168.178.1/255.255.255.0 or leave blank for all")</font></P>
<p>$(lang de:"Netbios Name" en:"Netbios Name"): <input type="text" name="netbios_name" size="20" maxlength="255" value="$(html "$SAMBA_NETBIOS_NAME")"></p>
<p>$(lang de:"Arbeitsgruppe" en:"Workgroup"): <input type="text" name="workgroup" size="20" maxlength="255" value="$(html "$SAMBA_WORKGROUP")"></p>
<p>$(lang de:"Beschreibung" en:"Description"):<br><input type="text" name="server_string" size="40" maxlength="255" value="$(html "$SAMBA_SERVER_STRING")"></p>
<p>$(lang de:"OS Level f&uuml;r Election" en:"OS level election"): <input type="text" name="os_level" size="5" maxlength="5" value="$(html "$SAMBA_OS_LEVEL")"></p>
<p>
<input type="hidden" name="master" value="no">
<input id="m1" type="checkbox" name="master" value="yes"$master_chk><label for="m1">$(lang de:"Bevorzugter Master" en:"Preferred Master")</label>
</p>
EOF

sec_end
