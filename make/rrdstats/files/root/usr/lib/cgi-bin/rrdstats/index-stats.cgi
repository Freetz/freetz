#!/bin/sh

. /usr/lib/libmodcgi.sh

cgi_begin "RRDstats"

source /usr/lib/cgi-bin/rrdstats/stats.cgi

cgi_end
