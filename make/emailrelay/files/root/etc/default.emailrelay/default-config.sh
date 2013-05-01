#!/bin/sh
. /mod/etc/conf/emailrelay.cfg

cat << EOF > /tmp/flash/emailrelay/emailrelay.conf

# do NOT change
log
close-stderr
user emailrelay
spool-dir /var/spool/emailrelay
pid-file /var/run/emailrelay.pid

# as you need it
as-server
#anonymous
#remote-clients
#interface 192.168.178.1
#filter /tmp/flash/emailrelay/emailrelay-filter
#server-auth /tmp/flash/emailrelay/emailrelay.auth
#client-auth /tmp/flash/emailrelay/emailrelay.auth
#client-tls
#server-tls /tmp/flash/emailrelay/emailrelay.pem
#connection-timeout 10
#domain fritz.box
#forward
#forward-to smarthost.mydomain.net
#immediate
#log-time
#poll 120
#port 587
#response-timeout 60
#verbose
#verifier /tmp/flash/emailrelay/emailrelay-verifier
#pop
#pop-port 110
#pop-auth /tmp/flash/emailrelay/emailrelay.auth
#pop-no-delete
#pop-by-name

EOF

