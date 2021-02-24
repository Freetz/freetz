#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

select "$NETATALK_LOG_LEVEL" \
  LOG_SEVERE:logsevere \
  LOG_ERROR:logerror \
  LOG_WARN:logwarn \
  LOG_INFO:loginfo \
  LOG_DEBUG:logdebug \
  LOG_MAXDEBUG:logmaxdebug \
	"*":lognote

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$NETATALK_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cat << EOF
<ul>
<li><a href='$(href file netatalk applevolumes_default)'>$(lang de:"Freigaben" en:"Shares") (AppleVolumes.default)</a></li>
<li><a href='$(href file netatalk afpd_conf)'>$(lang de:"Virtuelle Datei-Server" en:"Virtual fileservers") (afpd.conf)</a></li>
</ul>
EOF

sec_end
sec_begin "$(lang de:"Benutzer" en:"Users")"

cat << EOF
<p>
$(lang de:"Benutzer werden wie folgt angelegt und persistent gespeichert" en:"Create and persistently save users as follows"):
</p>
<ol>
<li>adduser -g 'Homer Simpson' hsimpson</li>
<li>modusers save</li>
<li>modsave flash</li>
</ol>
EOF

sec_end
sec_begin "$(lang de:"Netatalk" en:"Netatalk")"

cat << EOF
<p>
<label for='max_clients'>$(lang de:"Maximale Anzahl Verbindungen" en:"Maximum number of clients"): </label>
<input name='max_clients' type='text' size='4' maxlength='3' value='$(html "$NETATALK_MAX_CLIENTS")'>
</p>

<p>
<label for='log_level'>$(lang de:"Log-Level" en:"Log level"): </label>
<select name='log_level' id='log_level'>
<option $logsevere_sel>LOG_SEVERE</option>
<option $logerror_sel>LOG_ERROR</option>
<option $logwarn_sel>LOG_WARN</option>
<option $lognote_sel>LOG_NOTE</option>
<option $loginfo_sel>LOG_INFO</option>
<option $logdebug_sel>LOG_DEBUG</option>
<option $logmaxdebug_sel>LOG_MAXDEBUG</option>
</select>
</p>
EOF

sec_end
