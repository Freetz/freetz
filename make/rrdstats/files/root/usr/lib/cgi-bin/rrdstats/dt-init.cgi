#!/bin/sh
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
. /mod/etc/conf/rrdstats.cfg

# redirect stderr to stdout so we see ouput in webif
exec 2>&1

sec_begin '$(lang de:"Initialisiere DigiTemp" en:"Initializing DigiTemp")'

echo '<p><font size=+1><b><center>$(lang de:"BITTE WARTEN" en:"PLEASE WAIT")</center></b></font></p>'

[ -n "$RRDSTATS_DIGITEMPRS" ] && rs_param=" -s $RRDSTATS_DIGITEMPRS "

echo -n "<pre>"
/etc/init.d/rc.rrdstats stop
killall digitemp >/dev/null 2>&1
mkdir -p /tmp/flash/rrdstats
cd /tmp
digitemp $rs_param -i
mv .digitemprc /tmp/flash/rrdstats/digitemp.conf >/dev/null 2>&1
echo '</pre>'
modsave >/dev/null

echo -n '<p><input type="button" value="$(lang de:"Fenster Schliessen" en:"Close Window")" onclick="window.close()"/></p>'

sec_end

