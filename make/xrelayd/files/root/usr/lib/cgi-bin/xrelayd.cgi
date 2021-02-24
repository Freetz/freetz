#!/bin/sh

. /usr/lib/libmodcgi.sh

for i in 0 1 2 3 4 5 6 7; do
	select "$XRELAYD_VERBOSE" "$i":verbose${i}
done

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$XRELAYD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<h2>$(lang de:"Erweiterte Einstellungen" en:"Advanced settings"):</h2>
<p>$(lang de:"Log-Level" en:"Verbose level"):
<select name='verbose'>
<OPTION value="0"$verbose0_sel>0</OPTION>
<OPTION value="1"$verbose1_sel>1</OPTION>
<OPTION value="2"$verbose2_sel>2</OPTION>
<OPTION value="3"$verbose3_sel>3</OPTION>
<OPTION value="4"$verbose4_sel>4</OPTION>
<OPTION value="5"$verbose5_sel>5</OPTION>
<OPTION value="6"$verbose6_sel>6</OPTION>
<OPTION value="7"$verbose7_sel>7</OPTION>
</SELECT></p>
EOF
sec_end
sec_begin "$(lang de:"Dienste" en:"Services")"

cat << EOF
<ul>
<li><a href="$(href file xrelayd certchain)">$(lang de:"Zertifikats-Kette bearbeiten" en:"Edit certificate chain")</a></li>
<li><a href="$(href file xrelayd key)">$(lang de:"Privaten Schl&uuml;ssel bearbeiten" en:"Edit private key")</a></li>
<li><a href="$(href file xrelayd svcs)">$(lang de:"Dienste bearbeiten" en:"Edit services file")</a></li>
</ul>
EOF
sec_end
