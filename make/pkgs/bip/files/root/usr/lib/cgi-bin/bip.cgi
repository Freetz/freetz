#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$BIP_LOG" true:log
check "$BIP_LOG_SYSTEM" true:log_system

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$BIP_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<h2>$(lang de:"Port:" en:"Port:")</h2>
<p><input type="text" name="port" size="55" maxlength="250" value="$(html "$BIP_PORT")"></p>
<p>
<input type="hidden" name="log_system" value="false">
<input id="m2" type="checkbox" name="log_system" value="true"$log_system_chk><label for="m2">$(lang de:"Log System (bip internes Logsystem)" en:"Log System (bip's internal message logging)")</label>
</p>
<h2>$(lang de:"Loglevel:" en:"Loglevel:")</h2>
<p><input type="text" name="log_level" size="55" maxlength="250" value="$(html "$BIP_LOG_LEVEL")"></p>
<h2>$(lang de:"Log Root:" en:"Log root:")</h2>
<p><input type="text" name="log_root" size="55" maxlength="250" value="$(html "$BIP_LOG_ROOT")"></p>
<h2>$(lang de:"Log Format:" en:"Log format:")</h2>
<p><input type="text" name="log_format" size="55" maxlength="250" value="$(html "$BIP_LOG_FORMAT")"></p>
<p>
<input type="hidden" name="log" value="false">
<input id="m1" type="checkbox" name="log" value="true"$log_chk><label for="m1">$(lang de:"Log (Aktiviere logging und backlogging)" en:"Log (Enable logging and backlogging)")</label>
</p>
<h2>$(lang de:"Log Sync Interval:" en:"Log Sync Interval:")</h2>
<p><input type="text" name="log_sync_interval" size="55" maxlength="250" value="$(html "$BIP_LOG_SYNC_INTERVAL")"></p>
<h2>$(lang de:"Optionale Parameter (au&szlig;er -f):" en:"Optional parameters (except -f):")</h2>
<p><input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$BIP_CMDLINE")"></p>

EOF

sec_end
