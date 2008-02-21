#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''

if [ "$PPTPD_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end
sec_begin 'Konfigurationsdateien'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=chap_secrets">chap-secrets bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=pap_secrets">pap-secrets bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=options">options bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptpd_options">options.pptpd bearbeiten</a></li>
</ul>
EOF

sec_end
