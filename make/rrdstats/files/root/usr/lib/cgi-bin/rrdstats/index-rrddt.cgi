#!/bin/sh

. /usr/lib/libmodcgi.sh

cgi_begin "DigiTemp"

source /usr/lib/cgi-bin/rrdstats/rrddt.cgi

cgi_end
