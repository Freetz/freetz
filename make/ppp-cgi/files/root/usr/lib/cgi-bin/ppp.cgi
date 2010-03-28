#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$PPP_GMODE" o3G p3G p2G o2G xXG
check "$PPP_ENABLED" yes:auto "*":man
check "$PPP_FALLBACK" yes:fallback

eval "$(modcgi branding:pkg:cmd mod_cgi)"

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
&nbsp;<a href="$(href status ppp ppplog)">$(lang de:"(anzeigen)" en:"(show)")</a>
</p>
<p>
$(lang de:"Dieses Skript vor Verbindungsaufbau ausf&uuml;hren" en:"Execute this script before dialin"):&nbsp;&nbsp;
<input type="text" name="checktimeout" size="45" maxlength="255" value="$(html "$PPP_SCRIPT_DIAL")">
</p>
<p>
$(lang de:"Dieses Skript nach Verbindungsabbau ausf&uuml;hren" en:"Execute this script after hangup"):&nbsp;
<input type="text" name="checktimeout" size="45" maxlength="255" value="$(html "$PPP_SCRIPT_HUP")">
</p>
<p>
$(lang de:"Befehls-TTY (zB /dev/ttyUSB1)" en:"Command-TTY (eg /dev/ttyUSB1)"):&nbsp;<input type="text" name="diagtty" size="45" maxlength="255" value="$(html "$PPP_DIAGTTY")">
</p>
EOF
sec_end

if [ -n "$PPP_DIAGTTY" ]; then
sec_begin '$(lang de:"Modus" en:"Mode")'
if [ -n "$MOD_CGI_CMD" ] && [ -n "$PPP_DIAGTTY" ]; then
	outMOD=$MOD_CGI_CMD
	if [ "$MOD_CGI_CMD" = "o3G" ]; then
		outMOD="3G (ausschliesslich)"
		sysMOD="14,2"
	fi
	if [ "$MOD_CGI_CMD" = "p3G" ]; then
		outMOD="3G (bevorzugt)"
		sysMOD="2,2"
	fi
	if [ "$MOD_CGI_CMD" = "p2G" ]; then
		outMOD="2G (bevorzugt)"
		sysMOD="2,1"
	fi
	if [ "$MOD_CGI_CMD" = "o2G" ]; then
		outMOD="2G (ausschliesslich)"
		sysMOD=13,1
	fi
	[ -n "$sysMOD"] && echo -en "AT^SYSCFG=$sysMOD,3FFFFFFF,2,4\r" > $PPP_DIAGTTY &
	echo "<font color=red size=-1>Modus $outMOD gesetzt.</font>"
fi
cat << EOF
<p>
<input id="m2" type="radio" name="gmode" value="p3G"$p3G_chk><label for="m2"><a href="/cgi-bin/pkgconf.cgi?pkg=ppp&cmd=p3G">3G $(lang de:"bevorzugt" en:"preferred")</a></label>
&nbsp;
<input id="m1" type="radio" name="gmode" value="o3G"$o3G_chk><label for="m1"><a href="/cgi-bin/pkgconf.cgi?pkg=ppp&cmd=o3G">3G $(lang de:"ausschliesslich" en:"only")</a></label>
&nbsp;
<input id="m3" type="radio" name="gmode" value="p2G"$p2G_chk><label for="m3"><a href="/cgi-bin/pkgconf.cgi?pkg=ppp&cmd=p2G">2G $(lang de:"bevorzugt" en:"preferred")</a></label>
&nbsp;
<input id="m4" type="radio" name="gmode" value="o2G"$o2G_chk><label for="m4"><a href="/cgi-bin/pkgconf.cgi?pkg=ppp&cmd=o2G">2G $(lang de:"ausschliesslich" en:"only")</a></label>
&nbsp;
<input id="m0" type="radio" name="gmode" value="xXG"$xXG_chk><label for="m0">$(lang de:"nicht gesetzt" en:"not selected")</label>
</p>
EOF
sec_end
fi

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
&nbsp;<a href="$(href status ppp ppplog)">$(lang de:"(anzeigen)" en:"(show)")</a>
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
