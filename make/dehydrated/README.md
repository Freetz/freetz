# Dehydrated
Mit Dehydrated (und LigHTTPd) können Let's Encrypt Zertifikate erstellt und automatisch aktualisiert werden.
<br>

### Zertifikat erstellen
 * LigHTTPd so konfigurieren, dass über das Internet unter dem dyndns-Namen via http erreichbar ist (mit "webproxy"-Seite prüfen)
 * in dehydrated die "Optionen" entsprechend ausfüllen (eMail ist optional)
 * ```rc.dehydrated init``` ausführen
 * den angezeigten Befehl zur (einmaligen) Registrierung ausführen
 * nochmal ```rc.dehydrated init``` ausführen

### Zertifikat benutzen
 * in LigHTTPd unter "erweitert" einen vhost für https mit den Pfaden zum Zertifikat eintragen
 * oder die ssl.pem und fullchain.pem übers webif von LigHTTPd eintragen.
 * noch besser ( falls nur 1 Domaingenutzt wird) die dehydrated Zertifikate so verlinken:
```
rm -f /tmp/flash/lighttpd/ca.pem
ln -s /var/media/ftp/.. ../dehydrated/DOMAIN/fullchain.pem /tmp/flash/lighttpd/ca.pem
rm -f /tmp/flash/lighttpd/crt.pem
ln -s /var/media/ftp/.. ../dehydrated/DOMAIN/ssl.pem  /tmp/flash/lighttpd/crt.pem
modsave
rc.lighttpd restart
```

