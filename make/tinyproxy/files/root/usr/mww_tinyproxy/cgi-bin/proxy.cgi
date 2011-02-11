#!/bin/sh

. /mod/etc/conf/tinyproxy.cfg

cat << EOF
Content-type: text/plain; charset=UTF-8

function FindProxyForURL(url, host) {
        if ((url.substring(0,5) == "http:" || url.substring(0,6) == "https:") && url.substring(0,16) != "http://fritz.box") {
                return "PROXY fritz.box:$TINYPROXY_PORT";
        }
        else {
                return "DIRECT";
        }
}