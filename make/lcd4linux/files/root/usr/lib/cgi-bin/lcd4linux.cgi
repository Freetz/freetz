#!/bin/sh

. /usr/lib/libmodcgi.sh
. /usr/lib/libmodredir.sh

check "$LCD4LINUX_OUTPUT" yes:output
check "$LCD4LINUX_STATUSPAGE" yes:statuspage
check "$LCD4LINUX_WEBENABLED" yes:webenabled
check "$LCD4LINUX_WEB_INETD" yes:web_inetd


sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$LCD4LINUX_ENABLED" "" "" 0
sec_end


if [ "$(/mod/etc/init.d/rc.lcd4linux status)" == "running" -a "$LCD4LINUX_OUTPUT" == "yes" ]; then
if [ "$LCD4LINUX_WEBENABLED" = "yes" -o "$LCD4LINUX_STATUSPAGE" = "yes" ]; then
sec_begin "$(lang de:"Anzeigen" en:"Show")"

if [ "$LCD4LINUX_STATUSPAGE" = "yes" ]; then
cat << EOF
<ul>
<li><a href="$(href status lcd4linux stats)?refresh=10">$(lang de:"Statusseite anzeigen" en:"Show status page")</a></li>
</ul>
EOF
fi

if [ "$LCD4LINUX_WEBENABLED" = "yes" ]; then
cat << EOF
<ul>
<li><a href="http://$(self_host):$LCD4LINUX_WEB_PORT/?refresh=10" target="_blank">$(lang de:"Webseite anzeigen" en:"Show web site")</a></li>
</ul>
EOF
fi

sec_end
fi
fi


sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<p>
<input type="hidden" name="output" value="no">
<input id="o" type="checkbox" name="output" value="yes"$output_chk>
<label for="o">$(lang de:"Schreibe Ausgabedatei" en:"Write output file")</label>
</p>
EOF

if [ "$LCD4LINUX_OUTPUT" == "yes" ]; then
cat << EOF
$(lang de:"Ausgabedatei (png):" en:"Out file (png):")
<p><input type="text" name="outfile" size="55" maxlength="250" value="$(html "$LCD4LINUX_OUTFILE")"></p>
EOF
fi

cat << EOF
<h2>$(lang de:"Optionale Parameter (au&szlig;er -o):" en:"Optional parameters (except -o):")</h2>
<p><input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$LCD4LINUX_CMDLINE")"></p>
EOF

sec_end


if [ "$LCD4LINUX_OUTPUT" == "yes" ]; then
sec_begin "$(lang de:"Ausgabe" en:"Output")"

cat << EOF
<p>
<input type="hidden" name="statuspage" value="no">
<input id="s" type="checkbox" name="statuspage" value="yes"$statuspage_chk>
<label for="s">$(lang de:"Statusseite aktiveren" en:"Activate status page")</label>
</p>
<p>
<input type="hidden" name="webenabled" value="no">
<input id="w" type="checkbox" name="webenabled" value="yes"$webenabled_chk>
<label for="w">$(lang de:"Webserver aktiveren auf Port" en:"Activate webserver on port")&nbsp;</label>
<input type="text" name="web_port" size="4" maxlength="5" value="$(html "$LCD4LINUX_WEB_PORT")">
</p>
EOF

if [ "$LCD4LINUX_WEBENABLED" = "yes" -a -x /mod/etc/init.d/rc.inetd ]; then
cat << EOF
<p>
<input type="hidden" name="web_inetd" value="no">
<input id="i" type="checkbox" name="web_inetd" value="yes"$web_inetd_chk>
<label for="i">$(lang de:"Aktiviere inetd Nutzung" en:"Activate inetd support")</label>
</p>
EOF
fi

sec_end
fi

