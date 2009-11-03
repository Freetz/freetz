#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk='';

if [ "$PPP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

sec_begin '$(lang de:"Starttyp" en:"Start type")'
cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1">$(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2">$(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end

sec_begin '$(lang de:"Konfigurationsdateien" en:"Configuration files")'
cat << EOF
<li><a href="/cgi-bin/file.cgi?id=peers_options">PEERS: options</a></li>
<li><a href="/cgi-bin/file.cgi?id=peers_chat">PEERS: chat</a></li>
EOF
sec_end

sec_begin '$(lang de:"Einstellungen" en:"Settings")'
cat << EOF
<p>$(lang de:"Logdatei" en:"Logfile"):&nbsp;<input type="text" name="logfile" size="45" maxlength="255" value="$(html "$PPP_LOGFILE")"></p>
EOF
sec_end

