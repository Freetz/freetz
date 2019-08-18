#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$ADAWAY_ENABLED" yes:auto_c "*":man_c
check "$ADAWAY_LOGLEVEL" 0:loglevel_c0 1:loglevel_c1 2:loglevel_c2 3:loglevel_c3 5:loglevel_c5 6:loglevel_c6 7:loglevel_c7 "*":loglevel_c4

sec_begin 'Activation'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_c_chk><label for="e1"> Automatic</label>
<input id="e2" type="radio" name="enabled" value="no"$man_c_chk><label for="e2"> Manual</label>
</p>
EOF

sec_end
sec_begin 'AdAway blocking status'
ADAWAY_BLOCK_COUNT=`wc -l /tmp/hosts.adaway | awk '{print $1}'`

cat << EOF
Number of blocking domains: $ADAWAY_BLOCK_COUNT<br>
EOF

sec_end
sec_begin 'AdAway daemon'

cat << EOT
Download ad hosts files via HTTP-Proxy:<br>
<span style="font-size:10px;">leave blank for no proxy</span><br>
<input id="downloadproxy" type="text" name="download_proxy" size="40" maxlength="40" value="$(html "$ADAWAY_DOWNLOAD_PROXY")"><p>

Update interval:<br><span style="font-size:10px;">The ad hosts files will be periodically downloaded and applied when needed.</span><br>
<input id="downloadinterval" type="text" name="download_interval" size="5" maxlength="5" value="$(html "$ADAWAY_DOWNLOAD_INTERVAL")"> sec<p>

Target IP address:<br><span style="font-size:10px;">Domains of ad hosts files will be resolved to this IP address.</span><br>
<input id="targetip" type="text" name="target_ip" size="15" maxlength="15" value="$(html "$ADAWAY_TARGET_IP")"><p>

CA-file:<br><span style="font-size:10px;">trusted CA-File for https provider</span><br>
<input id="cafile" type="text" name="cafile" size="40" maxlength="80" value="$(html "$ADAWAY_CAFILE")"><p>

Debug level:<br>
<span style="font-size:10px;">Logging via syslog. Logging is disabled if syslog logger (/usr/sbin/logger) does not exist.</span><br>
<input id="loglevel0" type="radio" name="loglevel" value="0"$loglevel_c0_chk><label for="loglevel0">Emergency</label></br>
<input id="loglevel1" type="radio" name="loglevel" value="1"$loglevel_c1_chk><label for="loglevel1">Alert</label></br>
<input id="loglevel2" type="radio" name="loglevel" value="2"$loglevel_c2_chk><label for="loglevel2">Critical</label></br>
<input id="loglevel3" type="radio" name="loglevel" value="3"$loglevel_c3_chk><label for="loglevel3">Error</label></br>
<input id="loglevel4" type="radio" name="loglevel" value="4"$loglevel_c4_chk><label for="loglevel4">Warning</label></br>
<input id="loglevel5" type="radio" name="loglevel" value="5"$loglevel_c5_chk><label for="loglevel5">Notice</label></br>
<input id="loglevel6" type="radio" name="loglevel" value="6"$loglevel_c6_chk><label for="loglevel6">Informational</label></br>
<input id="loglevel7" type="radio" name="loglevel" value="7"$loglevel_c7_chk><label for="loglevel7">Debug</label></br>
EOT

sec_end
sec_begin 'Ad hosts provider'

cat << EOT
<ul><li><a href="$(href file adaway ad_hosts_provider)">Edit ad hosts provider</a></li></ul>
EOT

sec_end
