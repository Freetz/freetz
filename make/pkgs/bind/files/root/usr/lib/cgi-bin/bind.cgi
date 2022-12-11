#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$BIND_MULTID" yes:multid
check "$BIND_WRAPPER" yes:wrapper

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$BIND_ENABLED" "" "" 0
if [ "$FREETZ_AVM_HAS_DNSCRASH" != "y" ]; then
if [ "$EXTERNAL_FREETZ_PACKAGE_BIND_NAMED" != "y" ]; then
cat << EOF
<p>
<input type="hidden" name="wrapper" value="no">
<input id="e1" type="checkbox" name="wrapper" value="yes"$wrapper_chk><label for="w1"> $(lang de:"vor multid starten" en:"start before multid")</label><br>
</p>
EOF
fi
fi
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cat << EOF
<p>
$(lang de:"Optionale Parameter:" en:"Optional parameters:")
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$BIND_CMDLINE")">
</p>
EOF
if [ "$FREETZ_AVM_HAS_DNSCRASH" != "y" ]; then
if [ "$FREETZ_AVMDAEMON_DISABLE_DNS" != "y" ]; then
cat << EOF
<p>
<input type="hidden" name="multid" value="no">
<input id="m1" type="checkbox" name="multid" value="yes"$multid_chk><label for="m1">$(lang de:"Neustarten von multid um Port 53 nutzen zu k&ouml;nnen." en:"Restart multid to use port 53.")</label>
</p>
EOF
fi
fi
sec_end

