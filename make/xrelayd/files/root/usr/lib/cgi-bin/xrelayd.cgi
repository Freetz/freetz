#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_c_chk=''; man_c_chk=''
auto_s_chk=''; man_s_chk=''

if [ "$XRELAYD_ENABLED" = "yes" ]; then auto_c_chk=' checked'; else man_c_chk=' checked'; fi

case "$XRELAYD_VERBOSE" in 
		0) verbose_sel0=' selected' ;; 
		1) verbose_sel1=' selected' ;; 
		2) verbose_sel2=' selected' ;; 
		3) verbose_sel3=' selected' ;; 
		4) verbose_sel4=' selected' ;; 
		5) verbose_sel5=' selected' ;; 
		6) verbose_sel6=' selected' ;; 
		7) verbose_sel7=' selected' ;; 
esac 

sec_begin '$(lang de:"Starttyp" en:"Start type")'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_c_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_c_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF

sec_end
sec_begin '$(lang de:"Konfiguration" en:"Configuration")'

cat << EOF
<h2>$(lang de:"Erweiterte Einstellungen" en:"Advanced settings"):</h2>
<p>$(lang de:"Log-Level" en:"Verbose level"):
<select name='verbose'>
<OPTION value="0"$verbose_sel0>0</OPTION>
<OPTION value="1"$verbose_sel1>1</OPTION>
<OPTION value="2"$verbose_sel2>2</OPTION>
<OPTION value="3"$verbose_sel3>3</OPTION>
<OPTION value="4"$verbose_sel4>4</OPTION>
<OPTION value="5"$verbose_sel5>5</OPTION>
<OPTION value="6"$verbose_sel6>6</OPTION>
<OPTION value="7"$verbose_sel7>7</OPTION>
</SELECT></p>
EOF
sec_end
sec_begin '$(lang de:"Dienste" en:"Services")'

cat << EOF
<ul>
<li><a href="/cgi-bin/file.cgi?id=xrelayd_certchain">$(lang de:"Zertifikats-Kette bearbeiten" en:"Edit certificate chain")</a></li>
<li><a href="/cgi-bin/file.cgi?id=xrelayd_key">$(lang de:"Privaten Schlüssel bearbeiten" en:"Edit private key")</a></li>
<li><a href="/cgi-bin/file.cgi?id=xrelayd_svcs">$(lang de:"Dienste bearbeiten" en:"Edit services file")</a></li>
</ul>
EOF
sec_end
