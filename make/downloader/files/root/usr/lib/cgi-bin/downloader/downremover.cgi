#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

SELF='downremover'
TITLE='$(lang de:"Downloader - Aufräumen" en:"Downloader - Removing")'
NM_REMOVE='$(lang de:"Aufräumen" en:"Removing")'

cmd_button() {
local name=$1 act=$2 cmd=$3 label=$4 method=get
if [ -z $name ]; then
name="cmd"
fi
cat << EOF
<div class="btn">
<form class="btn" action="$act" method="$method">
EOF
if [ $cmd ]; then
cat << EOF
<input name="$name" value="$cmd" type="hidden">
EOF
fi
cat << EOF
<input value="$label" type="submit">
</form>
</div>
EOF
}

cgi_begin "$TITLE" extras
sec_begin "$NM_REMOVE"
if [ "$QUERY_STRING" ]; then
	eval "$QUERY_STRING"
	case $cmd in
		remove)
			echo -n "<pre>"
			/etc/init.d/rc.downloader remove
			echo "</pre>"
			back_button "$(href cgi downloader)"
			;;
		*)
			cat << EOF
<p>
$(lang de:"Falscher Parameter" en:"Wrong parameter") $cmd
</p>
EOF
			;;
		esac
else
cat << EOF
<p>
$(lang de:"Alle vom Downloader heruntergeladenen Dateien vom Zielort löschen.<br>Bitte nicht vergessen vorher die dazugehörigen Dienste zu stoppen!" en:"Removing of all by Downloader downloaded files.<br>Please do not forget to stop before all appropriate services!")
</p>
EOF
	cmd_button "" $SELF "remove" "$NM_REMOVE"
	back_button "$(href cgi downloader)"
fi
sec_end

cgi_end
