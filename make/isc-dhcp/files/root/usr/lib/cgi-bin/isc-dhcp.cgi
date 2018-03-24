#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$ISC_DHCP_MULTID" yes:multid
check "$ISC_DHCP_WRAPPER" yes:wrapper

sec_begin "Start type"
cgi_print_radiogroup_service_starttype "enabled" "$ISC_DHCP_ENABLED" "" "" 0
if [ "$EXTERNAL_FREETZ_PACKAGE_ISC_DHCP" != "y" ]; then
cat << EOF
<p>
<input type="hidden" name="wrapper" value="no">
<input id="e1" type="checkbox" name="wrapper" value="yes"$wrapper_chk><label for="w1"> start before multid</label><br>
</p>
EOF
fi
sec_end

sec_begin Configuration
cat << EOF
<p>
Optional parameters:
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$ISC_DHCP_CMDLINE")">
</p>
EOF
if [ "$FREETZ_AVMDAEMON_DISABLE_DNS" != "y" ]; then
cat << EOF
<p>
<input type="hidden" name="multid" value="no">
<input id="m1" type="checkbox" name="multid" value="yes"$multid_chk><label for="m1">Restart multid to use port 63</label>
</p>
EOF
fi
sec_end
