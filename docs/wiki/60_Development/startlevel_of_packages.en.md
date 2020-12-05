# STARTLEVEL of packages
List of packages which do not use the default STARTLEVEL 99.

 * Hardcoded
    - 00: crond
    - 00: telnetd
    - 00: webcfg

 * Basics
    - 10: inotify-tools
    - 11: usbroot
    - 12: syslogd-cgi
    - 13: downloader
    - 14: inetd

 * Interfaces
    - 20: cpmaccfg-cgi
    - 20: virtualip-cgi
 * Firewall
    - 25: iptables-cgi
    - 25: nhipt

 * SSH
    - 30: authorized-keys
    - 30: ca-bundle
    - 30: dropbear

 * DNS
    - 40: bind           (multid-wrapper may start it earlier!)
    - 40: dnsmasq        (multid-wrapper may start it earlier!)

 * Mounting
    - 50: autofs
    - 50: cifsmount
    - 50: davfs2

 * Various
    - 60: oidentd        (before bip, before ngircd)
    - 60: openntpd

 * Telefon
    - 71: callmonitor
 * Tunnel
    - 81: openconnect
    - 81: openvpn
    - 81: ppp-cgi
    - 81: pppd
    - 81: stunnel
    - 81: vpnc
    - 81: vtun
    - 81: wireguard
 * Routing
    - 82: bird
    - 82: quagga

 * Misc
    - 90: dbus           (before avahi)
    - 90: php            (before lighttpd)
    - 90: sundtek        (before rrdstats)

<br>To generate this:<br>
```
grep STARTLEVEL make/*/*.mk | sed -rn 's/.*\/(.*)\.mk:\$\(PKG\)_STARTLEVEL=([0-9]*) *(.*)/    - \2: \1\3/p' | sort | sed -r 's/# (.*)/\t\t (\1)/g'
```

