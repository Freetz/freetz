#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$USBIP_ALL" yes:all
check "$USBIP_STORAGES" yes:storages
check "$USBIP_HUBS" yes:hubs

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$USBIP_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Momentan verbundene Ger&auml;te" en:"Currently connected devices")"
USBIP_DEVICES_CONNECTED="$(usbip_bind_driver --list | grep -v "^List USB devices$")"
cat << EOF

<pre class='log'>
$USBIP_DEVICES_CONNECTED
</pre>

EOF
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cat << EOF

<p>
<input type="hidden" name="all" value="no">
<input id="c1" type="checkbox" name="all" value="yes"$all_chk><label for="c1">$(lang de:"Alle Ger&auml;te freigeben (au&szlig;er Datentr&auml;gern und Hubs)" en:"Share all devices (except storages and hubs)")</label>
</p>

<p>
<input type="hidden" name="storages" value="no">
<input id="c2" type="checkbox" name="storages" value="yes"$storages_chk><label for="c2">$(lang de:"Datentr&auml;ger freigeben" en:"Share storages")</label>
</p>

<p>
<input type="hidden" name="hubs" value="no">
<input id="c3" type="checkbox" name="hubs" value="yes"$hubs_chk><label for="c1">$(lang de:"USB-Hubs freigeben" en:"Share usb-hubs")</label>
</p>

<p>$(lang de:"Diese Ger&auml;te freigeben" en:"Shared these devices") (Syntax: &lt;VID&gt;:&lt;PID&gt;):<br>
<textarea name="custom" rows="9" cols="55" maxlength="255">$(html "$USBIP_CUSTOM")</textarea>
</p>

EOF
sec_end
