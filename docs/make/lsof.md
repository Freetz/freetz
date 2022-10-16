# lsof 4.89
 - Package: [master/make/pkgs/lsof/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/lsof/)

Mit `lsof` lässt sich feststellen, welche Dateien wo und von wem gerade
geöffnet sind. Dies kann sehr hilfreich sein, wenn man z.B. ein
angeschlossenes Wechselmedium (USB-Stick oder USB-Festplatte) von der
Box entfernen will, sich das Dateisystem aber nicht "unmounten" lässt,
weil es noch in Benutzung ist ("still in use") - mount sagt einem ja
nur, dass dem so sei, gibt aber keine Details bekannt.

Beispiel:

```
# lsof /var
COMMAND     PID     USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
syslogd     350     root    5w  VREG  222,5        0 440818 /var/adm/messages
syslogd     350     root    6w  VREG  222,5   339098   6248 /var/log/syslog
cron        353     root  cwd   VDIR  222,5      512 254550 /var -- atjobs
```

Weitere Informationen finden sich u.a. bei
[Wikipedia](http://en.wikipedia.org/wiki/Lsof).

