#!/bin/sh


PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=freetz


cgi_begin '$(lang de:"&Uuml;ber" en:"About")'
cat << EOF | sed -r 's/(.+[^>])$/\1<br>/g'
<center>

<h1>Developers</h1>
abraxXl
buehmann
cuma
er13
kriegaex
markuschen
olistudent
ralf
Whoopie
</p>

<p>
<h1>Supporters</h1>
cinereous
derheimi
hermann72pb
hippie2000
MaxMuster
M66B
sf3978
</p>

<p>
<h1>Freshmen</h1>
dileks
reiffert
</p>

<p>
<h1>Retired</h1>
aholler
johnbock
maz
McNetic
mickey
mike
</p>

<p>
<h1>Contributors</h1>
2DO
</p>

</center>
EOF
cgi_end
