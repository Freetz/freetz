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
cuma
hippie2000
kriegaex
magenbrot
olistudent
</p>

<p>
<h1>Unknown</h1>
er13
</p>

<p>
<h1>Retired</h1>
abraxXl
aholler
buehmann
cinereous
derheimi
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
