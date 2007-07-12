#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin 'Setup'

cat << EOF
<p>$(lang de:"Das Passwort f&uuml;r die DS-MOD Weboberfl&auml;che ist nicht gesetzt. Folgende &Auml;nderungen sollten nur &uuml;ber vertrauensw&uuml;rdige Netze geschehen (z.B. eigenes LAN), da die Passw&ouml;rter unverschl&uuml;sselt &uuml;bertragen werden." en:"There is no password set for the the DS-MOD webinterface. The following instructions should be performed in a trustful network environment only (e.g. your own LAN), because passwords will be send unencrypted.")</p>
<ol>
<li>
EOF

if [ -z "$(pidof telnetd)" ]; then
	echo '<form action="/cgi-bin/exec.cgi" method="post">'
	echo '<input type="hidden" name="cmd" value="telnetd">'
	echo '$(lang de:"Starte telnetd" en:"Start telnetd"): <input type="submit" value="$(lang de:"telnetd starten" en:"Start telnetd")...">'
	echo '</form>'
else
	echo '<span style="color:#008000;">$(lang de:"telnetd ist gestartet." en:"telnetd is running.")</span>'
fi

cat << EOF
</li>
<li>
$(lang de:"Logge dich auf der Box ein" en:"Login to your device"):
<pre>> telnet fritz.box 23
Trying 192.168.178.1...
Connected to fritz.box.
Escape character is '^]'.
fritz.box login: root
Password:
 __  __                 __   __
|  \(_  __ |\/| _  _|    _) /__
|__/__)    |  |(_)(_|__ /__ \__)

   The fun has just begun...

BusyBox v1.5.1 (2007.07.27-21:10+0000) Built-in shell (ash)
Enter 'help' for a list of built-in commands.

ermittle die aktuelle TTY
tty is "/dev/pts/0"
Console Ausgaben auf dieses Terminal umgelenkt
~ #
</pre>
</li>
<li>
$(lang de:"Mit dem Kommando <pre>modpasswd</pre> l&auml;sst sich nun das 'root' Passwort und das Passwort f&uuml;r die Weboberfl&auml;che setzen. Falls das 'root' Passwort unver&auml;ndert bleiben soll (z.B. dropbear braucht ein 'root' Passwort, gen&uuml;gt: <pre>modpasswd dsmod</pre>" en:"You can change the 'root' password and the password for the webinterface by using the command: <pre>modpasswd</pre> If you don't want to change the 'root' password (e.g. dropbear needs a 'root' password)<pre>modpasswd dsmod</pre> is sufficient.")
$(lang de:"Folgende Passw&ouml;rter sind zu unterscheiden:" en:"It is important to distinguish the following passwords:")
<ul>
<li>$(lang de:"FRITZ!Box Kennwort der original Firmware" en:"FRITZ!Box web password of original firmware")</li>
<li>$(lang de:"Passwort f&uuml;r die ds-mod Weboberfl&auml;che" en:"Password for the ds-mod webinterface")</li>
<li>$(lang de:"Passwort f&uuml;r den Benutzer 'root'" en:"Password for the user 'root'")</li>
</ul>
</li>
<li>
<form action="/cgi-bin/exec.cgi" method="post">
<input type="hidden" name="cmd" value="reboot">
Reboot: <input type="submit" value="$(lang de:"Box neustarten..." en:"Reboot device...")">
</form>
</li>
</ol>
EOF

cgi_end
