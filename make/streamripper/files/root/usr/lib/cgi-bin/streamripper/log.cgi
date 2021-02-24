#!/bin/sh

. /usr/lib/libmodcgi.sh

. /mod/etc/conf/streamripper.cfg

cgi_begin "Streamripper"
sec_begin "$(lang de:"Liste aller gerippten Dateien" en:"List of ripped files")"

echo "<p>$(lang de:"Per Copy&Paste in die Filterregeln &uuml;bernehmen" en:"Copy&Paste to filter rules")</p>"
echo -n "<div class='textwrapper'><textarea name='content' rows='30' cols='60' wrap='off' readonly>"
[ -e $STREAMRIPPER_MUSICDIR ] && \
find "$STREAMRIPPER_MUSICDIR" -iname '*.mp3' | sed 's/.*\/\(.*\).mp3/m\/\1\/x/' | sort | html
echo -n "</textarea></div>"
echo -n "<p><div class='btn'>"
echo -n "<form class='btn' action='$(href file streamripper filter)'><input type='submit' value='zu den Filterregeln'></form>"
echo -n "</div></p>"

sec_end
cgi_end
