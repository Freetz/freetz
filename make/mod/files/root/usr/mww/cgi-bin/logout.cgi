#!/bin/sh

SID="$(echo "$HTTP_COOKIE" | sed -n "s%.*SID=\([^\; ]*\).*%\1%p")"
rm -f /tmp/$SID.webcfg
isauth=0
QUERY_STRING=""
source /usr/mww/cgi-bin/login.cgi
