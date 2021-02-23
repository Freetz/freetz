#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$SYSLOGD_NETWORK" yes:network
check "$SYSLOGD_LOCAL" yes:local
check "$SYSLOGD_KLOGD" yes:klogd
check "$SYSLOGD_LOGGING" log_to_file circular_buffer

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SYSLOGD_ENABLED" "" "" 0
sec_end

if [ "$SYSLOGD_LOCAL" = "yes" ]; then
sec_begin "$(lang de:"Anzeigen" en:"Extra")"

cat << EOF
<ul>
<li><a href="$(href status syslogd log)">$(lang de:"Logdatei/Ringpuffer" en:"Log viewer")</a></li>
</ul>
EOF
sec_end
fi
sec_begin "$(lang de:"Optionen" en:"Options")"

cat << EOF
<input type="hidden" name="network" value="no">
<h2>
<input id="r1" type="checkbox" name="network" value="yes"$network_chk>
<label for="r1">$(lang de:"&Uuml;ber Netzwerk loggen" en:"Network logger")</label>
</h2>
<ul>
<li style="list-style-type: none">
<p>
<label for="r2">Host:</label>
<input id="r2" type="text" name="host" size="20" maxlength="20" value="$(html "$SYSLOGD_HOST")">
<label for="r11">Port:</label>
<input id="r11" type="text" name="port" size="5" maxlength="6" value="$(html "$SYSLOGD_PORT")">
</p>
</li>
</ul>
<input type="hidden" name="local" value="no">
<h2>
<input id="r9" type="checkbox" name="local" value="yes"$local_chk>
<label for="r9">$(lang de:"Lokal loggen" en:"Local logger")</label>
</h2>
<ul>
<li style="list-style-type: none">
<h2>
<input id="r3" type="radio" name="logging" value="log_to_file"$log_to_file_chk>
<label for="r3">$(lang de:"in Logfile" en:"in logfile") (/var/log/messages)</label>
</h2>
<ul>
<li style="list-style-type: none">
<label for="r4">$(lang de:"alternatives Logfile" en:"Log file location"):</label>
<input id="r4" type="text" name="alternative_logfile" size="30" maxlength="255" value="$(html "$SYSLOGD_ALTERNATIVE_LOGFILE")">
</li>
<li style="list-style-type: none">
<p>$(lang de:"Logfiles rotieren" en:"Log file rotation"):</p>
<ul>
<li style="list-style-type: none">
<label for="r5">$(lang de:"maximale Logfilegr&ouml;&szlig;e" en:"Max log file size") (in KB):</label>
<input id="r5" type="text" name="maxsize" size="6" maxlength="6" value="$(html "$SYSLOGD_MAXSIZE")">
<br>
<label for="r10">$(lang de:"Anzahl Logdateien" en:"Max number of logs to keep"):</label>
<input id="r10" type="text" name="maxfiles" size="2" maxlength="2" value="$(html "$SYSLOGD_MAXFILES")">
</li>
</ul>
</li>
</ul>
</li>
<li style="list-style-type: none">
<h2>
<input id="r6" type="radio" name="logging" value="circular_buffer"$circular_buffer_chk>
<label for="r6">$(lang de:"in Ringpuffer" en:"In memory buffer")</label>
</h2>
<ul>
<li style="list-style-type: none">
<label for="r7">$(lang de:"Puffer-Gr&ouml;&szlig;e" en:"") (in KB):</label>
<input id="r7" type="text" name="buffer_maxsize" size="5" maxlength="255" value="$(html "$SYSLOGD_BUFFER_MAXSIZE")">
</li>
</ul>
</li>
</ul>
<h2></h2>
EOF

if [ "$FREETZ_BUSYBOX_KLOGD" == "y" ]; then
cat << EOF
<input type="hidden" name="klogd" value="no">
<h2>
<input id="r12" type="checkbox" name="klogd" value="yes"$klogd_chk>
<label for="r12">$(lang de:"Kernel-Log-D&auml;mon aktivieren" en:"Activate kernel-log daemon")</label>
</h2>
<ul>
<li style="list-style-type: none">
<label for="r13">$(lang de:"Loglevel klogd" en:"Kernel Daemon (klogd) loglevel"): </label>
<input id="r13" type="text" name="klogd_level" size="2" maxlength="1" value="$(html "$SYSLOGD_KLOGD_LEVEL")">
</li>
</ul>
EOF
fi

cat << EOF
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten):" en:"Additional command line options (for experts)")</h2>
<label for="r8">$(lang de:"Optionen" en:"Options"):</label>
<input id="r8" type="text" name="expert_options" size="20" maxlength="255" value="$(html "$SYSLOGD_EXPERT_OPTIONS")">

EOF

sec_end

