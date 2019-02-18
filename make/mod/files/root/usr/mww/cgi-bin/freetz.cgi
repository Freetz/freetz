#!/bin/sh


PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=freetz


cgi_begin '$(lang de:"&Uuml;ber" en:"About")'
cat << EOF | sed -r 's/(.+[^>])$/\1<br>/g'
<center>

<h1>Developers</h1>
You!
</p>

<p>
<h1>Supporters</h1>
hippie2000
magenbrot
</p>

<p>
<h1>Decision supervision</h1>
derheimi
kriegaex
olistudent
</p>

<p>
<h1>Retired</h1>
abraxXl
aholler
buehmann
cinereous
cuma
er13
hermann72pb
johnbock
M66B
markuschen
MaxMuster
maz
McNetic
mickey
mike
ralf
reiffert
sf3978
Whoopie
</p>

</center>
EOF
cgi_end
