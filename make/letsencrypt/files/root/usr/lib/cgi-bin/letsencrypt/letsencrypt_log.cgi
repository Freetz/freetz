#!/bin/sh

. /usr/lib/libmodcgi.sh
. /mod/etc/conf/letsencrypt.cfg

echo "<h1>Let's Encrypt logfile $(realpath $LETSENCRYPT_LOGFILE)</h1>"
if [ -f "$LETSENCRYPT_LOGFILE" ]; then
        echo -n '<pre class="log full">'
        html < "$LETSENCRYPT_LOGFILE"
        echo '</pre>'
else
        html "$(lang de:"Die Logdatei ist leer." en:"The log file is empty.")"
fi

