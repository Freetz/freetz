#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/var/mod/sbin
. /usr/lib/libmodcgi.sh

VERSION="1.1"

check "$IPTABLES_ENABLED" yes:auto "*":man

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<div style="float: right;"><font size="1">Version: $VERSION</font></div>
<p>
<input id="e1" type="radio" name="enabled" value="yes" $auto_chk><label for="e1"> Automatic</label>
<input id="e2" type="radio" name="enabled" value="no" $man_chk><label for="e2"> Manual</label>
</p>
EOF
sec_end
