#!/bin/sh

if [ -n "${QUERY_STRING##*hash=}" ]; then
	source /usr/mww/cgi-bin/login_check.sh
else
	source /usr/mww/cgi-bin/login_page.sh
fi

