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
er13
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
reiffert
sf3978
</p>

<p>
<h1>Retired</h1>
aholler
cuma
johnbock
kriegaex
maz
McNetic
mickey
mike
</p>

</center>
EOF
cgi_end
