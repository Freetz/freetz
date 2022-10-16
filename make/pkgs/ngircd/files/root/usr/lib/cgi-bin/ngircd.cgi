#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$NGIRCD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<p>
<a href="$(href file ngircd conf)">$(lang de:"Zum Bearbeiten der ngircd.conf hier klicken." en:"To edit the ngircd.conf click here.")</a>
</p>
<p>
$(lang de:"Optionale Parameter (au&szlig;er -p und -f):" en:"Optional parameters (except -p and -f):")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$NGIRCD_CMDLINE")">
</p>
EOF

sec_end
