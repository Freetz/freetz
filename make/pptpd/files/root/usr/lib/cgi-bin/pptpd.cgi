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
<li><a href="/cgi-bin/file.cgi?id=chap_secrets">PPP: chap-secrets bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptpd_options">PPTPD: options.pptpd bearbeiten</a></li>
<li><a href="/cgi-bin/file.cgi?id=pptpd_conf">PPTPD: Konfiguration bearbeiten</a></li>
</ul>
EOF
#<li><a href="/cgi-bin/file.cgi?id=pap_secrets">PPP: pap-secrets bearbeiten</a></li>
#<li><a href="/cgi-bin/file.cgi?id=options">PPP: options bearbeiten</a></li>

sec_end
