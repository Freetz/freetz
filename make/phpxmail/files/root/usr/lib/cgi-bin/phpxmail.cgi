#!/bin/sh


. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"PHPXmail" en:"PHPXmail")"
cat << EOF
<p>$(lang de:"Die Konfigurationsoberfl&auml;che kann" en:"You and open the configuration site") <b><a style='font-size:14px;' target='_blank' href=/phpxmail/index.php>$(lang de:"hier" en:"here")</a></b>$(lang de:" ge&ouml;ffnet werden." en:".")<p>
EOF
sec_end
