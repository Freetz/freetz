#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$OIDENTD_ENABLED" "" "" 1
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<p>
$(lang de:"Optionale Parameter (au&szlig;er -I und -C):" en:"Optional parameters (except -I and -C):")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$OIDENTD_CMDLINE")">
</p>
EOF

sec_end
