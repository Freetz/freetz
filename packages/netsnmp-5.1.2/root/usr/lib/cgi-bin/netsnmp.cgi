#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
 
auto_chk=''; man_chk=''
 
if [ "$NETSNMP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
 
sec_begin 'Starttyp'
 
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF
 
sec_end
