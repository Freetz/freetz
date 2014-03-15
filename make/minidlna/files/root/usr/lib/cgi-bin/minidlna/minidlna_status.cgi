#!/bin/sh

. /mod/etc/conf/minidlna.cfg
. /usr/lib/libmodcgi.sh
. /usr/lib/libmodredir.sh

eval "$(modcgi branding:pkg:cmd mod_cgi)"

if [ -n "$MOD_CGI_CMD" ]; then
	sec_begin '$(lang de:"Hinweis" en:"Remark")'
	echo "<font size=-2 color=red><br>$(lang de:"Die Datenbank wird neu aufgebaut. Dies kann eine Weile dauern." en:"The database is being rebuilt. This may take a while.")<br></font>"
	sec_end
	/mod/etc/init.d/rc.minidlna rescan >/dev/null 2>&1
fi

if [ "$(/mod/etc/init.d/rc.minidlna status)" != "running" ]; then
echo "<br>$(lang de:"MiniDLNA ist nicht gestartet." en:"MiniDLNA is not running.")"
else
cat << EOF
<center>

<pre class="log">
<iframe src="http://$(self_host):${MINIDLNA_PORT}/" frameborder="0" width="100%" height="400" allowTransparency="true"></iframe>
</pre>

<form class="btn" action="$(href status minidlna minidlna_status)" method="post" style="display:inline;">
<input type="hidden" name="cmd" value="rescan">
<input type="submit" value="$(lang de:"neu einlesen" en:"rescan")">
</form>
&nbsp;&nbsp;&nbsp;
<form class="btn" action="$(href status minidlna minidlna_status)" method="post" style="display:inline;">
<input type="hidden" name="cmd" value="">
<input type="submit" value="$(lang de:"aktualisieren" en:"refresh")">
</form>

</center>
EOF
fi
