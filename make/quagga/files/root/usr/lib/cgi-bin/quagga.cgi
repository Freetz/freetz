#!/bin/sh
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

daemonlist="bgpd ripd ripngd ospfd ospf6d isisd"
for daemon in $daemonlist; do
[ -x /usr/sbin/$daemon ] && daemons="$daemons $daemon"
done

auto_chk=''; man_chk=''
if [ "$QUAGGA_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'
 
cat << EOF
<p><input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label
for="e1"> $(lang de:"Automatisch" en:"Automatic")</label><input id="e2" type="radio"
name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label></p>
EOF
 
sec_end
sec_begin '$(lang de:"Routing-Daemonen" en:"Routing daemons")'

echo '<ul>'

for daemon in $daemons; do
r1_chk=''; r2_chk=''
ucdaemon=$(echo "$daemon" | awk '{print toupper($1)}')
if [ "$(eval echo \$QUAGGA_$ucdaemon)" = "yes" ]; then r1_chk=' checked'; else r2_chk=' checked'; fi
cat << EOF
<li>$ucdaemon: <input id="${daemon}1" type="radio" name="$daemon" value="yes"$r1_chk><label
for="${daemon}1"> $(lang de:"Aktiviert" en:"Enabled")</label><input id="${daemon}2" type="radio"
name="$daemon" value="no"$r2_chk><label for="${daemon}2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</li>
EOF
done

echo "</ul>"

sec_end
sec_begin '$(lang de:"Konfigurationsdatei(en)" en:"Configuration file(s)")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=zebra_conf">$(lang de:"zebra.conf bearbeiten" en:"Edit zebra.conf")</a></li>
EOF

for daemon in $daemons; do
cat << EOF
<li><a href="/cgi-bin/file.cgi?id=${daemon}_conf">$(lang de:"${daemon}.conf bearbeiten" en:"Edit ${daemon}.conf")</a></li>
EOF
done

echo "</ul>"

sec_end
