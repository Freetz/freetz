# Troubleshooting Build-Abbruch

Sollte während des Build-Prozesses ein Abbruch auftreten, so kann man versuchen diese Strategien anzuwenden:

 * Einzelnes Paketes erneut erstellen:
```
	$ make iptables-dirclean     <--- Sourceverzeichnis eines problematischen Package löschen (hier: iptables)
	weiter mit
	$ make iptables-precompiled  <--- Versuchen problematisches Package von Anfang neu zu bauen
```

 * Von Anfang neu bauen:
```
	$ make dirclean          <--- Source-Verzeichnisse aller bisher erstellter Software löschen
	weiter mit
	$ make                   <--- Versuchen problematische Software von Anfang neu zu bauen
```

Bei Nichterfolg können Wiki, Forum und IRC genutzt werden, um das Problem weiter zu behandeln.


