#!/bin/sh


PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=freetz

# (svn log --quiet | sed -rn 's/^r[^|]*.([^|]*).*/\1/p' ; echo -e 'hermann72pb\nhippie2000\njohnbock\nM66B\nmagenbrot\nreiffert\nsf3978') | sort -u | sed 's/ //g' | grep -vE '^(root|administrator|fda77|oliver)$'
cgi_begin '$(lang de:"&Uuml;ber" en:"About")'
cat << EOF | sed -r 's/(.+[^>])$/\1<br>/g'
<center>

<p>
<h1>Supporters</h1>
abraXxl
aholler
berndy2001
buehmann
BugReporter-ilKY
cawidtu
cinereous
cm8
cuma
derheimi
er13
f-666
feedzapper
fidelio-dev
flosch-dev
forenuser
hermann72pb
hippie2000
horle
JasperMichalke
JBBgameich
johnbock
kriegaex
M66B
magenbrot
markuschen
martinkoehler
MaxMuster
maz
McNetic
mickey
mike
mrtnmtth
Oliver
PeterPawn
ralf
reiffert
RolfLeggewie
sf3978
sfritz
smischke
stblassitude
telsch
thiloms
Whoopie
WileC
</p>

</center>
EOF
cgi_end
