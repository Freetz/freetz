#!/bin/sh
. /mod/etc/conf/sslh.cfg

cat << EOF > /tmp/flash/sslh/protocols
{ name: "ssh"; service: "ssh"; host: "localhost"; port: "22"; probe: "builtin"; },
{ name: "openvpn"; host: "localhost"; port: "1194"; probe: "builtin"; },
{ name: "xmpp"; host: "localhost"; port: "5222"; probe: [ "jabber" ]; },
{ name: "http"; host: "localhost"; port: "80"; probe: "builtin"; },
{ name: "ssl"; host: "localhost"; port: "443"; probe: "builtin"; },
{ name: "timeout"; service: "daytime"; host: "localhost"; port: "daytime"; }
EOF
