#!/bin/sh

if  $(echo "$QUERY_STRING" | grep -q genconfigname ); then
	NAME=${QUERY_STRING##*genconfigname=}
	sh /etc/default.openvpn/generate_virtual_pkg "$NAME"
	sed -i "/$NAME/ d" /tmp/flash/openvpn/configs
	echo "$NAME" >> /tmp/flash/openvpn/configs
fi

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cginame=${0##*/}
pkgname=${cginame%%.cgi}
if [ "openvpn" == ${pkgname} ]; then
	filepath=/tmp/flash/openvpn/
else
	filepath=/tmp/flash/openvpn/${pkgname}/
fi
check $OPENVPN_ENABLED yes:auto inetd "*":man
check $OPENVPN_EXTCLIENT yes:clients

sec_begin '$(lang de:"Starttyp" en:"Start type")' sec_start

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes" $auto_chk><label for="e1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="e2" type="radio" name="enabled" value="no" $man_chk><label for="e2"> $(lang de:"Manuell" en:"Manual")</label>
$([ -e "/etc/default.inetd/inetd.cfg" ] && \
	echo '<input id="e3" type="radio" name="enabled" value="inetd"'$inetd_chk'><label for="e3"> Inetd</label>')
</p>
EOF

sec_end
sec_begin '$(lang de:"Einstellungen" en:"Configuration")' sec_conf

cat << EOF
$(lang de:"Hinweis: Zertifikate und Keys liegen unter " en:"Certs and keys are located ") <i>${filepath}</i>
<p><div align="center"><textarea id="id_conf" style="width: 500px;" name="conf" rows="15" cols="80" wrap="off" >$OPENVPN_CONF</textarea></div></p>


EOF

sec_end
