#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk='' man_chk=''
if [ "$SYSLOGD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

network_chk='' local_chk='' klogd_chk=''
if [ "$SYSLOGD_NETWORK" = "yes" ]; then network_chk=' checked'; fi
if [ "$SYSLOGD_LOCAL" = "yes" ]; then local_chk=' checked'; fi
if [ "$SYSLOGD_KLOGD" = "yes" ]; then klogd_chk=' checked'; fi

log_to_file_chk='' circular_buffer_chk='' 
case "$SYSLOGD_LOGGING" in
	log_to_file) log_to_file_chk=' checked' ;;
	circular_buffer) circular_buffer_chk=' checked' ;;
esac

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk> <label for="e1">Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk> <label for="e2">Manuell</label>
</p>
EOF

sec_end
sec_begin 'Anzeigen'

cat << EOF
<ul>
<li><a href="/cgi-bin/extras.cgi/syslogd/log">Logdatei/Ringpuffer</a></li>
<li><a href="/cgi-bin/extras.cgi/syslogd/help">Hilfe</a></li>
</ul>
EOF
sec_end
sec_begin 'Optionen'

cat << EOF
<input type="hidden" name="network" value="no">
<h2>
<input id="r1" type="checkbox" name="network" value="yes"$network_chk>
<label for="r1">&Uuml;ber Netzwerk loggen</label>
</h2>
<ul>
<li style="list-style-type: none">
<p>
<label for="r2">Host:</label>
<input id="r2" type="text" name="host" size="20" maxlength="20" value="$(httpd -e "$SYSLOGD_HOST")">
<label for="r11">Port:</label>
<input id="r11" type="text" name="port" size="5" maxlength="6" value="$(httpd -e "$SYSLOGD_PORT")"> 
</p>
</li>
</ul>
<input type="hidden" name="local" value="no">
<h2>
<input id="r9" type="checkbox" name="local" value="yes"$local_chk>
<label for="r9">Lokal loggen</label>
</h2>
<ul>
<li style="list-style-type: none">
<h2>
<input id="r3" type="radio" name="logging" value="log_to_file"$log_to_file_chk>
<label for="r3">in Logfile</label>
</h2>
<ul>
<li style="list-style-type: none">
<label for="r4">alternatives Logfile:</label>
<input id="r4" type="text" name="alternative_logfile" size="30" maxlength="255" value="$(httpd -e "$SYSLOGD_ALTERNATIVE_LOGFILE")">
</li>
<li style="list-style-type: none">
<p>Logfiles rotieren:</p>
<ul>
<li style="list-style-type: none">
<label for="r5">maximale Logfilegr&ouml;&szlig;e (in KB):</label>
<input id="r5" type="text" name="maxsize" size="6" maxlength="6" value="$(httpd -e "$SYSLOGD_MAXSIZE")"> 
<br>
<label for="r10">Anzahl Logdateien:</label>
<input id="r10" type="text" name="maxfiles" size="2" maxlength="2" value="$(httpd -e "$SYSLOGD_MAXFILES")">
</li>
</ul>
</li>
</ul>
</li>
<li style="list-style-type: none">
<h2>
<input id="r6" type="radio" name="logging" value="circular_buffer"$circular_buffer_chk>
<label for="r6">in Ringpuffer</label>
</h2>
<ul>
<li style="list-style-type: none">
<label for="r7">Puffer-Gr&ouml;&szlig;e (in KB):</label>
<input id="r7" type="text" name="buffer_maxsize" size="5" maxlength="255" value="$(httpd -e "$SYSLOGD_BUFFER_MAXSIZE")">
</li>
</ul>
</li>
</ul>
<h2></h2>
<input type="hidden" name="klogd" value="no">
<h2>
<input id="r12" type="checkbox" name="klogd" value="yes"$klogd_chk>
<label for="r12">Kernel-Log D&auml;mon aktivieren</label>
</h2>
<h2>Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten):</h2>
<label for="r8">Optionen:</label>
<input id="r8" type="text" name="expert_options" size="20" maxlength="255" value="$(httpd -e "$SYSLOGD_EXPERT_OPTIONS")">

EOF

sec_end
