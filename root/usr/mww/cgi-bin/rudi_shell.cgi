#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

if [ "$sec_level" -gt "0" ]; then

cgi_begin '$(lang de:"Rudi(ment&auml;r)-Shell" en:"Rudi(mentary) Shell")' 'rudishell'
echo '<p><div style="color: #800000;">$(lang de:"Rudi-Shell ist in der aktuellen Sicherheitsstufe nicht verf&uuml;gbar!" en:"Rudi shell is not available at the current security level!")</div></p>'

else

cgi_begin '$(lang de:"Rudi(ment&auml;r)-Shell" en:"Rudi(mentary) Shell")'
cat << EOF
	<script type=text/javascript>
		hist = Array()
		function setShellOutput(txt) {
			var parent = document.getElementById("shell_output")
			parent.replaceChild(document.createTextNode(txt), parent.firstChild)
			hist.push(new Array(document.getElementById("script_code").value, txt))
			var opt = new Option("#" + (hist.length - 1));
			document.getElementById("history")[hist.length - 1] = opt;
			document.getElementById("history").selectedIndex = 0
		}
		function historySelected(index) {
			document.getElementById("script_code").value = hist[hist.length - 1 - index][0]
			var parent = document.getElementById("shell_output")
			parent.replaceChild(document.createTextNode(hist[hist.length - 1 - index][1]), parent.firstChild)
		}
		function cleanHistory() {
			hist = Array()
			var list = document.getElementById("history")
			while (list.length > 0)
				list.remove(0)
		}
		function copyOut2Cmd(){
			document.getElementById("script_code").value = document.getElementById("shell_output").firstChild.nodeValue;
		}
		function RudiEdit() {
			file = document.getElementById("file2edit").value;
			LF="%0A"
			tdata = "cat " + file;
			tcmd = 'script=' +
				'echo "%23%23 $(lang de:"Rudi-Editor" en:"Rudi Editor")"' + LF +
				'echo "%23%23 $(lang de:"Bitte umgebende Zeilen NICHT l&ouml;schen" en:"Please DO NOT delete surrounding lines") (\'cat > ...\', \'RUDI_EOF\')"' + LF +
				'echo "cat > '+ file + ' << \'RUDI_EOF\'"' + LF +
				tdata + LF +
				'echo "RUDI_EOF"';
			tmp = '/cgi-bin/rudi_shellcmd.cgi?pid=$$&onload=parent.copyOut2Cmd()&' + tcmd;
			parent.frames["shellcmd"].location.href = tmp;
		}
	</script>
	<form action="/cgi-bin/rudi_shellcmd.cgi?pid=$$" target="shellcmd" method=POST enctype="multipart/form-data">
		<textarea id="script_code" name="script" rows="10" cols="80"></textarea><p>
		<input type=submit value="$(lang de:"Skript ausf&uuml;hren" en:"Run script")">&nbsp;&nbsp;
		$(lang de:"Historie" en:"History") <select id="history" onChange="historySelected(this.selectedIndex)"></select>
		<input type=button value="$(lang de:"Hist. l&ouml;schen" en:"Delete hist.")" onClick="cleanHistory()">&nbsp;&nbsp;
		<input type="checkbox" name="display_mode" value="binary">Download
		(<input type="checkbox" name="tar" value="true">.tar
		<input type="checkbox" name="gz" value="true">.gz )
	</form>
	<table>
		<form action="/cgi-bin/rudi_upload.cgi?pid=$$" target="shellcmd" method=POST enctype="multipart/form-data">
			<tr><td>$(lang de:"Quelldatei" en:"Source file")</td><td><input type=file name="source" size=50></td></tr>
			<tr><td>$(lang de:"Zieldatei" en:"Target file")</td><td><input name="target" value="/var/tmp/rudi_upload" size=50> <input type=submit value="$(lang de:"Hochladen" en:"Upload")"></td></tr>
		</form>
		<tr><td>$(lang de:"Rudi-Edit" en:"Rudi edit")</td><td> <input id="file2edit" value="/var/tmp/tmp.txt" size=50> <input type=button value="$(lang de:"Datei editieren" en:"Edit file")" onClick="RudiEdit()"></td></tr>
	</table>
	<iframe name="shellcmd" style="width: 0; height: 0; border: 0"></iframe>
	<pre id="shell_output">---</pre>
EOF

echo $$ > /var/run/rudi_shell.pid
fi

cgi_end
