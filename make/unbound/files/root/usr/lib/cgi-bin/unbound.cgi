#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg


sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$UNBOUND_ENABLED" "" "" 0
cgi_print_checkbox_p "wrapper" "$UNBOUND_WRAPPER" "$(lang de:"vor multid starten" en:"start before multid")"
[ "$FREETZ_AVMDAEMON_DISABLE_DNS" != "y" ] && \
  cgi_print_checkbox_p "multid_restart" "$UNBOUND_MULTID_RESTART" "$(lang de:"multid restarten" en:"restart multid")"
sec_end
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<p>
<a href="$(href file unbound conf)">$(lang de:"Zum Bearbeiten der unbound.conf hier klicken." en:"To edit the unbound.conf click here.")</a>
</p>
<p>
$(lang de:"Optionale Parameter:" en:"Optional parameters:")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$UNBOUND_CMDLINE")">
</p>
EOF

sec_end

