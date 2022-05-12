#!/bin/bash
# generates docs/JUIS.md
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname ${SCRIPT%/*})"
TOOLS="$PARENT/tools"


#rel
echo -e '\n### FOS-Release ################################################'
for x in $(seq 150 300); do  env - $TOOLS/juis_check        HW=$x                                     -a; done | tee fos-rel
#dwn
echo -e '\n### FOS-Downgrade ##############################################'
for x in $(seq 150 300); do  env - $TOOLS/juis_check --down HW=$x                                     -a; done | tee fos-dwn
#add
cat fos-dwn fos-rel | sort -u > fos-xxx
#( cat fos-rel ; cat fos-dwn | while read -s x; do grep -q "^${x%=*}=" fos-rel || echo $x; done ) | sort -u > fos-xxx
#( cat fos-dwn ; cat fos-rel | while read -s x; do grep -q "^${x%=*}=" fos-dwn || echo $x; done ) | sort -u > fos-xxx

#lab
echo -e '\n### FOS-Labor ##################################################'
for x in $(seq 200 300); do  [ "$x" -lt 248 2>/dev/null ] && m="$(( $x - 72 ))" || m=$x; m="$m.07.39-95000"
                             env - $TOOLS/juis_check        HW=$x         Buildtype=1001  Version=$m  -a; done | tee fos-lab
#inh
echo -e '\n### FOS-Inhaus #################################################'
for x in $(seq 200 300); do  [ "$x" -lt 248 2>/dev/null ] && m="$(( $x - 72 ))" || m=$x; m="$m.07.39-95000"
                             env - $TOOLS/juis_check        HW=$x         Buildtype=1000  Version=$m  -a; done | tee fos-inh
#sub
cat fos-xxx | while read -s x; do sed "/^${x//\//\\\/}$/d" -i fos-lab fos-inh; done
#cat fos-xxx | while read -s x; do sed "/\/${x##*/}$/d" -i fos-lab fos-inh; done


#dect-rel
echo -e '\n### Dect-Release ###############################################'
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";
                             env - $TOOLS/juis_check --dect HW=252 DHW=$x                             -a; done | tee dect-rel
#dect-lab
echo -e '\n### Dect-Labor #################################################'
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";             m="252.07.39-95000"
                             env - $TOOLS/juis_check --dect HW=252 DHW=$x Buildtype=1000  Version=$m  -a; done | tee dect-lab
#dect-inh
echo -e '\n### Dect-Inhaus ################################################'
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";             m="252.07.39-95000"
                             env - $TOOLS/juis_check --dect HW=252 DHW=$x Buildtype=1001  Version=$m  -a; done | tee dect-inh
#dect-sub
cat dect-rel | while read -s x; do sed "/\/${x##*/}$/d" -i dect-lab dect-inh; done
cat dect-lab | while read -s x; do sed "/\/${x##*/}$/d" -i          dect-inh; done


#bpjm
echo -e '\n### BPjM #######################################################'
                             env - $TOOLS/juis_check --bpjm HW=252                                    -a       | tee bpjm
[ ! -s bpjm ] || curl -sS "$(sed -n 's/.*=//p' bpjm)" -o bpjm.out
read="$(head -c4 bpjm.out | xxd -p)"
calc="$(crc32 <( tail -c +$((1 + 4)) bpjm.out ))"
[ "$read" != "$calc" ] && comp="mismatch $read/$calc" || comp="$read"
sed -i "s/.*=/$comp=/" bpjm


#gen
(
echo -n "Content: "
echo -e "FOS-Release\nFOS-Labor\nFOS-Inhaus\nDect-Release\nDect-Labor\nDect-Inhaus\nBPjM" \
  | while read cat; do echo -n "[$cat](#$(echo ${cat,,} | sed 's/ /-/g')) - "; done | sed 's/...$//'
echo
echo -e '# Links von AVM-Juis für FOS ab HWR 150 sowie Dect und BPjM'
echo -e ' - AVM nutzt unsichere http:// Links, daher muss die Signatur der Dateien vor Verwendung geprüft werden.'
echo -e ' - Sollten verschieden Links für ein Gerät angezeigt werden sind die Angaben von Juis inkonsistent.'
echo -e ' - Diese Liste ist weder vollständig, korrekt noch aktuell.'
echo -e '\n### FOS-Release'  ; cat fos-xxx  | while read -s x; do echo " - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### FOS-Labor'    ; cat fos-lab  | while read -s x; do echo " - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### FOS-Inhaus'   ; cat fos-inh  | while read -s x; do echo " - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Dect-Release' ; cat dect-rel | while read -s x; do echo " - MHW ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Dect-Labor'   ; cat dect-lab | while read -s x; do echo " - MHW ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Dect-Inhaus'  ; cat dect-inh | while read -s x; do echo " - MHW ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### BPjM'         ; cat bpjm     | while read -s x; do echo " - CRC ${x%=*}: [${x##*/}](${x#*=})"; done
) | sed 's/_-/-/' > $PARENT/docs/JUIS.md

#tmp
rm -f fos-xxx fos-rel fos-dwn fos-lab fos-inh  dect-rel dect-lab dect-inh  bpjm bpjm.out

