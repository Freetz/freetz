#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cgi_print_radiogroup_service_starttype "enabled" "$SYNCE_DCCM_ENABLED" "" "" 0
sec_end
