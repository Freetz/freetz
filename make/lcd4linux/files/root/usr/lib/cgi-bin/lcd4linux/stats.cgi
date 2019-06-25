#!/bin/sh
#by cuma


. /mod/etc/conf/lcd4linux.cfg


if [ "$LCD4LINUX_OUTFILE" != "/tmp/lcd4linux.png" ]; then
	rm -f "/tmp/lcd4linux.png"
	ln -s "$LCD4LINUX_OUTFILE" "/tmp/lcd4linux.png" 
fi

echo "<center>"
echo "<br />"
echo "<a href='${QUERY_STRING:+?$QUERY_STRING}' class='image'>"
echo "<p><img src='/l4l/lcd4linux.png?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')' alt='LCD4linux' border='0'/></p>"
echo "</a>"
echo "</center>"

