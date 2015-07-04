#!/bin/bash

for i in freetz/config-{ar9,ar10,iks,ur8,vr9}-*; do
	i=$(basename $i)
	sed -r -e 's,=n$,=m,' "avm/$i" | diff -du --label "avm/$i" --label "freetz/$i" - freetz/$i > $i.diff
done
