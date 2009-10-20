#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /mod/etc/conf/subversion.cfg

let _width=$_cgi_width-230

if [ -n "$SUBVERSION_LOGFILE" -a -f "$SUBVERSION_LOGFILE" -a -r "$SUBVERSION_LOGFILE" ]; then

cat << EOF
<h1>$(lang de:"Subversion-Logdatei" en:"Subversion log-file") $SUBVERSION_LOGFILE</h1>
<pre style="height: 480px; width: ${_width}px; overflow: auto;">
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
