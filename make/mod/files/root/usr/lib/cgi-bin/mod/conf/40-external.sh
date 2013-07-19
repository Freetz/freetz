if [ -x /mod/etc/init.d/rc.external ]; then
check "$MOD_EXTERNAL_WAIT_INFINITE" yes:external_wait_infinite_00 "*":external_wait_infinite_15

sec_begin 'external'
_services=$(cat /mod/etc/external.pkg 2>/dev/null)
[ -z "$_services" ] && _services=$(lang de:"-keine-" en:"-none-")

cgi_print_textline_p "external_directory" "$MOD_EXTERNAL_DIRECTORY" 55/255 "$(lang de:"Verzeichnis von external" en:"Directory for external"): "

cgi_print_checkbox_p "external_freetz_services" "$MOD_EXTERNAL_FREETZ_SERVICES" "$(lang de:"Folgende externalisierte Freetz-Dienste behandeln" en:"Manage these externalized services of Freetz")" ": $_services"

echo "<p>"
cgi_print_textline "external_own_services" "$MOD_EXTERNAL_OWN_SERVICES" 55/255 "$(lang de:"Diese selbst definierten Dienste behandeln" en:"Manage these own services"): "
cat << EOF
<FONT SIZE=-2><br><br>
$(lang de:"Hinweis: Namen der /mod/etc/init.d/rc.DAEMON Dateien ohne das f&uuml;hrende rc. und mit Leerzeichen getrennt angeben. " en:"Input the names of /mod/etc/init.d/rc.DAEMON files without rc., separated by space. ")
$(lang de:"Dies kann dazu genutzt werden um nicht externalisierte Dienste die ein USB-Ger&auml;t zum Speichern der Daten ben&ouml;tigen (wie RRDstats, Tor, bip, Xmail oder vnstat-cgi) zu starten und stoppen." en:"This would be helpful if a service is not externalized, but needs your USB-device for storing data-files (like RRDstats, Tor, bip, Xmail or vnstat-cgi).")
</FONT>
</p>

<h1>$(lang de:"Zeitsynchronisation" en:"Time-synchronisation")</h1>
<p>
EOF

cgi_print_checkbox "external_year_min" "$MOD_EXTERNAL_YEAR_MIN" "$(lang de:"Warte auf Zeitsynchronisation der Box (mindestens Jahr 2010)" en:"Wait for time synchronisation (year must be at least 2010)")"
cat << EOF
<blockquote>
<input id="s3" type="radio" name="external_wait_infinite" value="no"$external_wait_infinite_15_chk><label for="s3"> $(lang de:"Warte maximal 15 Minuten." en:"Wait maximum 15 minutes.")</label><br>
<input id="s4" type="radio" name="external_wait_infinite" value="yes"$external_wait_infinite_00_chk><label for="s4"> $(lang de:"Warte unbegrenzt." en:"Wait infinitely.")</label><br>
$(lang de:"Abbrechen falls die Jahreszahl gr&ouml;&szlig;er als dieser Wert ist" en:"Abort if the year is higher than this value"): <input type="text" name="external_year_max" size="3" maxlength="4" value="$(html "$MOD_EXTERNAL_YEAR_MAX")">
</blockquote>
</p>
EOF

sec_end
fi
