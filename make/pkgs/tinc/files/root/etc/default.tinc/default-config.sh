#!/bin/sh
. /mod/etc/conf/tinc.cfg


if [ -n "$TINC_SERVER1" -a ! -e "/tmp/flash/tinc/hosts/$TINC_SERVER1" ]; then
cat << EOF > "/tmp/flash/tinc/hosts/$TINC_SERVER1"
Address          = server1.dyndns.org
Port             = 10655

IndirectData     = no
PMTUDiscovery    = yes
Compression      = 0

Subnet           = 192.168.201.0/24
Subnet           = 192.168.200.201/32

-----BEGIN RSA PUBLIC KEY-----
#
-----END RSA PUBLIC KEY-----
EOF
fi


if [ -n "$TINC_SERVER2" -a ! -e "/tmp/flash/tinc/hosts/$TINC_SERVER2" ]; then
cat << EOF > "/tmp/flash/tinc/hosts/$TINC_SERVER2"
Address          = server2.dyndns.org
Port             = 10655

IndirectData     = no
PMTUDiscovery    = yes
Compression      = 0

Subnet           = 192.168.202.0/24
Subnet           = 192.168.200.202/32

-----BEGIN RSA PUBLIC KEY-----
#
-----END RSA PUBLIC KEY-----
EOF
fi


if [ -n "$TINC_SERVER3" -a ! -e "/tmp/flash/tinc/hosts/$TINC_SERVER3" ]; then
cat << EOF > "/tmp/flash/tinc/hosts/$TINC_SERVER3"
Address          = server3.dyndns.org
Port             = 10655

IndirectData     = no
PMTUDiscovery    = yes
Compression      = 0

Subnet           = 192.168.203.0/24
Subnet           = 192.168.200.203/32

-----BEGIN RSA PUBLIC KEY-----
#
-----END RSA PUBLIC KEY-----
EOF
fi


if [ ! -e /tmp/flash/tinc/tinc-down ]; then
cat << EOF > /tmp/flash/tinc/tinc-down
ifconfig \$INTERFACE down
EOF
chmod +x /tmp/flash/tinc/tinc-down
fi


if [ ! -e /tmp/flash/tinc/tinc-up ]; then
cat << EOF > /tmp/flash/tinc/tinc-up
ifconfig \$INTERFACE down
ifconfig \$INTERFACE 192.168.200.200 netmask 255.255.255.0 up
ifconfig \$INTERFACE up
#route add -net 192.168.201.0/24 gateway 192.168.200.201
#route add -net 192.168.202.0/24 gateway 192.168.200.202
#route add -net 192.168.203.0/24 gateway 192.168.200.203
EOF
chmod +x /tmp/flash/tinc/tinc-up
fi

