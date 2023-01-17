#!/bin/sh
. /mod/etc/conf/sslh.cfg

cat << EOF > /tmp/flash/sslh/protocols
{ name: "ssh"; service: "ssh"; host: "localhost"; port: "22"; },
{ name: "openvpn"; host: "localhost"; port: "1194"; },
{ name: "xmpp"; host: "localhost"; port: "5222"; },
{ name: "http"; host: "localhost"; port: "80"; },
{ name: "tls"; host: "localhost"; port: "443"; },
{ name: "timeout"; service: "daytime"; host: "localhost"; port: "daytime"; }
EOF
