# Onlinechanged-CGI
Ermöglicht das Ausführen von Skripten bei einer Änderung des Online-Statuses der Box.<br>
<br>

Dieses Feature ist ab r2850 (trunk) in Freetz und wurde implementiert weil AVM in der Firmware 54.04.67 das Verhalten von /bin/onlinechanged geändert hat.
Bisher handelte sich bei /bin/onlinechanged um ein Symlink auf das Skript /var/tmp/onlinechanged. Die Entstehung kann in Ticket #271 nachverfolgt werden.

Um das Verhalten zu vereinheitlichen gilt ab r2850 für /bin/onlinechanged: Beim Wechsel des Online Status wird das Skript vom multid mit online bzw. offline als Parameter aufgerufen und ruft dann selbst folgende Skripte auf:

 * /var/tmp/onlinechanged 	Kompatibilität zum alten Verhalten
 * /etc/onlinechanged/* 	neues AVM Verhalten
 * /tmp/flash/onlinechanged/* 	Skripte im Freetz Flash

Ein Skript in /etc/onlinechanged könnte zum Beispiel folgendermaßen aussehen:
```
#!/bin/sh

case "$1" in
   online)
      /etc/init.d/rc.package online
      ;;

   offline)
      /etc/init.d/rc.package offline
      ;;
esac
```

An application: update external IP-address for dnsd:
```
EXTIP="`/usr/bin/get_ip -d`"
sed "s/#EXTIP#/$EXTIP/g"</tmp/flash/dnsd/dnsd_template.conf >/tmp/flash/dnsd/dnsd.conf
modsave
/etc/init.d/rc.dnsd restart
logger -t dnsd "IP set to $EXTIP"
```

You can send yourself an e-mail when your box comes online like this:

```
   online)
      mailer -s "Freetz online" -t <your e-mail address>
      ;;
```

For this to work, you should configure the ​AVM Push service, but it is not necessary to enable it. 

