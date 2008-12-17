#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

[ -r "/mod/etc/conf/hp-utils.cfg" ] && . /mod/etc/conf/hp-utils.cfg

stat_bar() {
	percent=$1; let bar="percent*2"; let grey="(100-percent)*2"
	echo '<img src="/images/green.png" width="'"$bar"'" height="13" border="0" alt=""><img src="/images/grey.png" width="'"$grey"'" height="13" border="0" alt="">'
}
        
cgi_begin 'hp-utils'

action=${QUERY_STRING#action=}
sel=' style="background-color: #bae3ff;"'
supp_sel=''
maint_sel=''
maint_clean_sel=''
maint_align_sel=''
if [ -z "$action" ]; then
	maint_sel=$sel
elif [ "$action" = "clean" ]; then
	maint_clean_sel=$sel
elif [ "$action" = "align" ]; then
	maint_align_sel=$sel
fi

cat << EOF
<div class="menu">
<div$supp_sel><a href="/cgi-bin/index.cgi">$(lang de:"Verbrauchsmaterialien" en:"Supplies")</a></div>
<div$maint_sel><a href="/cgi-bin/maint.cgi">$(lang de:"Wartung" en:"Maintenance")</a></div>
<div$maint_clean_sel class="su"><a href="/cgi-bin/maint.cgi?action=clean">$(lang de:"Druckkopfreinigung" en:"Print Cartridge Cleaning")</a></div>
<div$maint_align_sel class="su"><a href="/cgi-bin/maint.cgi?action=align">$(lang de:"Druckkopfausrichtung" en:"Print Cartridge Alignment")</a></div>
</div>
EOF

sec_begin "$action"
echo "<p>$(lang de:"(noch) nicht implementiert" en:"not (yet) implemented")</p>"
sec_end

cgi_end
