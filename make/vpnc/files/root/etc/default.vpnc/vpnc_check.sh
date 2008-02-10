#!/bin/sh
if ping -c 3 $1; then
	echo "host available, existing"
else
	echo "host not available, killing vpnc"
	killall vpnc
	sleep 2
	echo "starting vpnc"
	cat /var/mod/etc/vpnc.conf | grep "#network 0.0.0.0" > /dev/nul
	if [ $? -eq 0 ]; then
		/sbin/vpnc --script /etc/default.vpnc/vpnc-script /mod/etc/vpnc.conf 
	else
		/sbin/vpnc --script /var/tmp/vpnc-script /mod/etc/vpnc.conf
	fi
fi
