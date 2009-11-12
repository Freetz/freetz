#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; fallback_chk='';

if [ "$PPP_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi
if [ "$PPP_FALLBACK" = "yes" ]; then fallback_chk=' checked'; fi

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
<p>
<ul>
<li><a href="/cgi-bin/file.cgi?id=peers_options">PEERS: options</a></li>
<li><a href="/cgi-bin/file.cgi?id=peers_chat">PEERS: chat</a></li>
</ul>
</p>
EOF
sec_end

sec_begin '$(lang de:"Einstellungen" en:"Settings")'
cat << EOF
<p>
$(lang de:"Allgemeine Logdatei" en:"Global logfile"):&nbsp;<input type="text" name="logfile" size="45" maxlength="255" value="$(html "$PPP_LOGFILE")">
&nbsp;<a href="/cgi-bin/pkgstatus.cgi?pkg=ppp&cgi=ppp/ppplog">$(lang de:"(anzeigen)" en:"(show)")</a>
</p>
<p>
$(lang de:"Dieses Skript vor Verbindungsaufbau ausf&uuml;hren" en:"Execute this script before dialin"):&nbsp;
<input type="text" name="checktimeout" size="45" maxlength="255" value="$(html "$PPP_SCRIPT_DIAL")">
</p>
<p>
$(lang de:"Dieses Skript nach Verbindungsabbau ausf&uuml;hren" en:"Execute this script after hangup"):&nbsp;
<input type="text" name="checktimeout" size="45" maxlength="255" value="$(html "$PPP_SCRIPT_HUP")">
</p>
EOF
sec_end

sec_begin '$(lang de:"Fallback" en:"Fallback")'
cat << EOF
<small style="font-size:0.8em">
Vorsicht! Dieses Feature ist experimentell und darf nur nach sorgf&auml;ltiger Pr&uuml;fung des Quelltextes auf eigene Gefahr hin aktiviert werden!
</small>
<p>
<input type="hidden" name="fallback" value="no">
<input id="f1" type="checkbox" name="fallback" value="yes"$fallback_chk><label for="f1">$(lang de:"Fallback aktiviert" en:"Fallback enabled")</label>
</p>
<p>
$(lang de:"Logdatei von Fallback" en:"Fallback-logfile"):&nbsp;<input type="text" name="fabalog" size="45" maxlength="255" value="$(html "$PPP_FABALOG")">
&nbsp;<a href="/cgi-bin/pkgstatus.cgi?pkg=ppp&cgi=ppp/ppplog">$(lang de:"(anzeigen)" en:"(show)")</a>
</p>
<p>
$(lang de:"Internetverbindung in diesem Intervall pr&uuml;fen" en:"Check connection in this intervall"):&nbsp;
<input type="text" name="checkinterval" size="2" maxlength="4" value="$(html "$PPP_CHECKINTERVAL")">
&nbsp;$(lang de:"Sekunden" en:"seconds")
</p>
<p>
$(lang de:"Alternative Verbindung aufbauen nach" en:"Establish alter connection after a timeout of"):&nbsp;
<input type="text" name="checktimeout" size="2" maxlength="4" value="$(html "$PPP_CHECKTIMEOUT")">
&nbsp;$(lang de:"Sekunden ohne Antwort" en:"seconds")
</p>
<p>
$(lang de:"Mit Leerzeichen getrennt Hosts zum pr&uuml;fen der Internetverbindung" en:"Space seperated hosts for check of the internet-connection"):&nbsp;<input type="text" name="checkhosts" size="45" maxlength="255" value="$(html "$PPP_CHECKHOSTS")">
</p>
<p>
$(lang de:"Host zum pr&uuml;fen auf Wiederherstellung (nicht erreichbar w&auml;hrend der Verbindung!)" en:"Host for online-again check (not reachable while dun-connection!)"):&nbsp;<input type="text" name="alivecheck" size="45" maxlength="255" value="$(html "$PPP_ALIVECHECK")">
</p>
EOF
sec_end

