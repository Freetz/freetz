if [ -x /etc/init.d/rc.external ]; then
check "$MOD_EXTERNAL_FREETZ_SERVICES" yes:external_freetz_services
check "$MOD_EXTERNAL_YEAR_MIN" yes:external_year_min
check "$MOD_EXTERNAL_WAIT_INFINITE" yes:external_wait_infinite_00 "*":external_wait_infinite_15

sec_begin 'external'
_services=`cat /etc/external.pkg 2>/dev/null`
[ -z "$_services" ] && _services=$(lang de:"-keine-" en:"-none-")
cat << EOF

<h1>$(lang de:"Automatisch Dienste starten/stoppen beim ein-/aush&auml;ngen" en:"Automatically start/stop services at (un)mount")</h1>
<p>
<input type="hidden" name="external_freetz_services" value="no">
<input id="e1" type="checkbox" name="external_freetz_services" value="yes"$external_freetz_services_chk>
<label for="e1">$(lang de:"Folgende externalisierte Freetz-Dienste behandeln" en:"Manage these externalised services of Freetz")</label>: $_services
</p>
<p>
$(lang de:"Diese selbst definierten Dienste behandeln:" en:"Manage these own services:")
<input type="text" name="external_own_services" size="55" maxlength="250" value="$(html "$MOD_EXTERNAL_OWN_SERVICES")">
<FONT SIZE=-2><br><br>
$(lang de:"Hinweis: Namen der /etc/init.d/rc.DAEMON Dateien ohne das f&uuml;hrende rc. und mit Leerzeichen getrennt angeben. " en:"Input the names of /etc/init.d/rc.DAEMON files without the rc., seperated by spacebar. ")
$(lang de:"Dies kann dazu genutzt werden um nicht externalisierte Dienste die ein USB-Ger&auml;t zum Speichern der Daten ben&ouml;tigen (wie RRDstats, Tor, bip, Xmail oder vnstat-cgi) zu starten und stoppen." en:"This would be helpful if a service is not externalised, but needs your USB-device for storing data-files (like wie RRDstats, Tor, bip, Xmail or vnstat-cgi).")
</FONT>
</p>

<h1>$(lang de:"Zeitsynchronisation" en:"Time-synchronisation")</h1>
<p>
<input type="hidden" name="external_year_min" value="no">
<input id="e2" type="checkbox" name="external_year_min" value="yes"$external_year_min_chk>
<label for="e2">$(lang de:"Warte auf Zeitsynchronisation der Box (mindestens Jahr 2010)" en:"Wait for time synchronisation (year must be at least 2010)")</label>
<blockquote>
<input id="s3" type="radio" name="external_wait_infinite" value="no"$external_wait_infinite_15_chk><label for="s3"> $(lang de:"Warte maximal 15 Minuten." en:"Wait maximal 15 minutes.")</label><br>
<input id="s4" type="radio" name="external_wait_infinite" value="yes"$external_wait_infinite_00_chk><label for="s4"> $(lang de:"Warte unbegrenzt." en:"Wait infinite.")</label><br>
$(lang de:"Abbrechen falls die Jahreszahl gr&ouml;&szlig;er als dieser Wert ist" en:"Abort if the year is higher than this value"): <input type="text" name="external_year_max" size="3" maxlength="4" value="$(html "$MOD_EXTERNAL_YEAR_MAX")">
</blockquote>
</p>

EOF
sec_end
fi
