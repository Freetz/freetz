#!/bin/bash

for i in freetz/config-{ar9,ar934x,ar10,grx5,iks,ipq40xx,puma6.x86,qca955x,qca956x,ur8,vr9}-*; do
	i=$(basename $i)
	sed -r -e 's,=n$,=m,' "avm/$i" | diff -du --label "avm/$i" --label "freetz/$i" - freetz/$i > $i.diff
done
