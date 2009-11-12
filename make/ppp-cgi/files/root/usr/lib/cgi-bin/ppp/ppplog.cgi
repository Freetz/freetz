#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

. /mod/etc/conf/ppp.cfg

let _width=$_cgi_width-230

echo "<h1>$(lang de:"Logdatei" en:"Logfile"): $PPP_LOGFILE</h1>"
echo -n '<textarea style="width: '$_width'px;" name="logfile" rows="25" cols="10" wrap="off" readonly>'
[ -e $PPP_LOGFILE ] && cat $PPP_LOGFILE | html
echo -n '</textarea>'

if [ -e $PPP_FABALOG ]; then
 echo "<br><br>"
 echo "<h1>$(lang de:"Fallback" en:"Fallback"): $PPP_FABALOG</h1>"
 echo -n '<textarea style="width: '$_width'px;" name="fallback" rows="25" cols="10" wrap="off" readonly>'
 [ -e $PPP_FABALOG ] && cat $PPP_FABALOG | html
 echo -n '</textarea>'
fi

