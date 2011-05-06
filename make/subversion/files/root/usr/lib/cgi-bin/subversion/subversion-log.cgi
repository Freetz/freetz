#!/bin/sh


. /usr/lib/libmodcgi.sh
. /mod/etc/conf/subversion.cfg

if [ -n "$SUBVERSION_LOGFILE" -a -f "$SUBVERSION_LOGFILE" -a -r "$SUBVERSION_LOGFILE" ]; then

cat << EOF
<h1>$(lang de:"Subversion-Logdatei" en:"Subversion log-file") $SUBVERSION_LOGFILE</h1>
<pre class="log full">
EOF
html < "$SUBVERSION_LOGFILE"
cat << EOF
</pre>
EOF

else

cat << EOF
<h1>$(lang de:"Subversion-Logdatei nicht vorhanden" en:"Subversion log-file not available")</h1>
EOF

fi
