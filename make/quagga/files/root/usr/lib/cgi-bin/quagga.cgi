#!/bin/sh

. /usr/lib/libmodcgi.sh

daemonlist="bgpd ripd ripngd ospfd ospf6d isisd"
for daemon in $daemonlist; do
[ -x /usr/sbin/$daemon ] && daemons="$daemons $daemon"
done

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$QUAGGA_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Routing-Daemonen" en:"Routing daemons")"

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
sec_begin "$(lang de:"Konfigurationsdatei(en)" en:"Configuration file(s)")"

cat << EOF
<ul>
<li><a href="$(href file quagga zebra_conf)">$(lang de:"zebra.conf bearbeiten" en:"Edit zebra.conf")</a></li>
EOF

for daemon in $daemons; do
cat << EOF
<li><a href="$(href file quagga "${daemon}_conf")">$(lang de:"${daemon}.conf bearbeiten" en:"Edit ${daemon}.conf")</a></li>
EOF
done

echo "</ul>"

sec_end
