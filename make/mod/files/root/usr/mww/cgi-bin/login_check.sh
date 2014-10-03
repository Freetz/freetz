#!/bin/sh

WRONGPW=0
ID_IP=$(cat /tmp/loginsid 2>/dev/null)
SID=${ID_IP%#*}
IP=${ID_IP#*#}
hash=${QUERY_STRING##*hash=}
UPWHASH=$(cat /tmp/flash/mod/webmd5 | tr -d '\n' )
myhash="$(echo -n "$SID$UPWHASH" | md5sum | sed 's/[ ]*-.*//')"

if [ "$REMOTE_ADDR" = "$IP" -a  "$hash" = "$myhash" ]; then
	touch /tmp/$SID.webcfg
else
	SENDSID=""
	QUERY_STRING=""
	WRONGPW=1
	. /usr/mww/cgi-bin/login_page.sh
fi
. /usr/mww/cgi-bin/index.cgi
