#!/bin/sh

echo '<h1>$(lang de:"Aktuelle Firmwareversion" en:"Latest firmware version")</h1>'

LAST="$(date -d @$(stat -c %Y /tmp/.juis_check) +'%d.%m.%Y %H:%M:%S' 2>/dev/null)"
echo "<ul><li>$(lang de:"Letzte &Uuml;berpr&uuml;fung" en:"Last check"): ${LAST:-niemals}</li></ul>"

vfromk() {
	sed -rn "s/.*<ns3:$1>(.*)<\/ns3:$1>.*/\1/p" /tmp/.juis_check 2>/dev/null
}
if [ -n "$LAST" ]; then
	echo '<pre>'
	if [ "$(vfromk Found)" == "true" ]; then
		echo "$(lang de:"Version" en:"Version"): <a title='$(vfromk Name)'>$(vfromk Version | sed 's/-/ rev/')</a>"
		echo "$(lang de:"Info" en:"Info"): <a target="_blank" href=$(vfromk InfoURL)>$(vfromk InfoText)<a/>"
		echo "$(lang de:"Download" en:"Download"): <a href=$(vfromk DownloadURL)>$(vfromk DownloadURL | sed 's/.*\///')<a/>"
	else
		echo "$(lang de:"Keine Firmware gefunden" en:"No firmware found")"
	fi
	echo '</pre>'
fi

stat_button juis_check '$(lang de:"Firmwareversion pr&uuml;fen" en:"Check firmware version")'

