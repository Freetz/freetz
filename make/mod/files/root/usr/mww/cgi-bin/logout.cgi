#!/bin/sh

if [ "$AUTH_TYPE" == "Basic" ]; then
	. /usr/lib/libmodredir.sh
	redirect_302 "$(self_prot)://$(sed -n 's/^\/cgi-bin\/invalidate.cgi://p' /mod/etc/webcfg.conf)@$(self_host)$(self_port)/cgi-bin/invalidate.cgi"
else
	SID="$(echo "$HTTP_COOKIE" | sed -n "s%.*SID=\([^\; ]*\).*%\1%p")"
	rm -f /tmp/$SID.webcfg
	isauth=0
	QUERY_STRING=""
	source /usr/mww/cgi-bin/login.cgi
fi

