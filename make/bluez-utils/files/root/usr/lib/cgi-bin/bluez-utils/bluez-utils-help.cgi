#!/bin/sh


. /mod/etc/conf/bluez-utils.cfg

echo "Content-type: text/html"
echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2//EN\">"
echo "<html>"
echo "<body><h1>Bluez Utils Help</h1>"

if [ -f "/etc/bluetooth/help.html" ]; then
	cat /etc/bluetooth/help.html
else
	echo "<p>Help not installed</p>"
fi

echo "<p><h1>System-Informations</h1></p>"

echo " <p><b><a name="reallinkkeys"> Hotplug script for pand - file: /var/lib/bluetooth/$BLUEZ_UTILS_MAC/linkkeys </b></p> "
cat /var/lib/bluetooth/$BLUEZ_UTILS_MAC/linkkeys | tr "\n" "²" | sed -e 's/²/<br>/g'
echo "<br><a href=\"javascript:history.back()\">Back</a><HR>"

echo "<p><b><a name="macaddr"> Information of bluetooth stick output from hciconfig</b></p> "
hciconfig | tr "\n" "²" | sed -e 's/²/<br>/g'
echo "<br><a href=\"javascript:history.back()\">Back</a><HR>"

echo "<p>End of help</p>"
echo "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
echo "</body></html>"
