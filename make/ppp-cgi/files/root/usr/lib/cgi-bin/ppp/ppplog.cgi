#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

. /mod/etc/conf/ppp.cfg

let _width=$_cgi_width-230
echo "<h1>$(lang de:"Logdatei" en:"logfile"): $PPP_LOGFILE</h1>"
echo -n '<textarea style="width: '$_width'px;" name="content" rows="30" cols="10" wrap="off" readonly>'
[ -e $PPP_LOGFILE ] && cat $PPP_LOGFILE | html
echo -n '</textarea>'

