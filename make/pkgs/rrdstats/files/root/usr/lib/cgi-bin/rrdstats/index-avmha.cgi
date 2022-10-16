#!/bin/sh

. /usr/lib/libmodcgi.sh

cgi_begin "SmartHome"

source /usr/lib/cgi-bin/rrdstats/avmha.cgi

cgi_end
