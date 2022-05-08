#!/bin/bash
# generates docs/JUIS.md
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname ${SCRIPT%/*})"
TOOLS="$PARENT/tools"


#rel
echo -e '\n### Release ####################################################'
for x in $(seq 150 300); do  env - $TOOLS/juis_check        HW=$x                              -a; done | tee rel
#dwn
echo -e '\n### Downgrade ##################################################'
for x in $(seq 150 300); do  env - $TOOLS/juis_check --down HW=$x                              -a; done | tee dwn
#add
cat dwn rel | sort -u > xxx
#( cat rel ; cat dwn | while read -s x; do grep -q "^${x%=*}=" rel || echo $x; done ) | sort -u > xxx
#( cat dwn ; cat rel | while read -s x; do grep -q "^${x%=*}=" dwn || echo $x; done ) | sort -u > xxx


#lab
echo -e '\n### Labor ######################################################'
for x in $(seq 200 300); do  [ "$x" -lt 248 2>/dev/null ] && m="$(( $x - 72 ))" || m=$x; m="$m.07.39-95000"
                             env - $TOOLS/juis_check        HW=$x  Buildtype=1001  Version=$m  -a; done | tee lab
#inh
echo -e '\n### Inhaus #####################################################'
for x in $(seq 200 300); do  [ "$x" -lt 248 2>/dev/null ] && m="$(( $x - 72 ))" || m=$x; m="$m.07.39-95000"
                             env - $TOOLS/juis_check        HW=$x  Buildtype=1000  Version=$m  -a; done | tee inh
#sub
cat xxx | while read -s x; do sed "/^${x//\//\\\/}$/d" -i lab inh; done


#dect
echo -e '\n### Dect #######################################################'
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; 
                             env - $TOOLS/juis_check --dect HW=252 DHW=${x::-1}.0${x:2}        -a; done | tee dect

#bpjm
echo -e '\n### BPjM #######################################################'
                             env - $TOOLS/juis_check --bpjm HW=252                             -a       | tee bpjm
[ ! -s bpjm ] || curl "$(sed -n 's/.*=//p' bpjm)" -o bpjm.out
read="$(head -c4 bpjm.out | xxd -p)"
calc="$(crc32 <( tail -c +$((1 + 4)) bpjm.out ))"
[ "$read" != "$calc" ] && comp="mismatch $read/$calc" || comp="$read"
sed -i "s/.*=/$comp=/" bpjm


#gen
(
echo -n "Content: "
echo -e "Release\nLabor\nInhaus\nDect\nBPjM" | while read cat; do echo -n "[$cat](#$(echo ${cat,,} | sed 's/ /-/g')) - "; done | sed 's/...$//'
echo
echo -e '# Links von AVM-Juis ab HWR 150'
echo -e ' - AVM nutzt unsichere http:// Links, daher muss die Signatur der Dateien vor Verwendung geprüft werden'
echo -e ' - Sollten verschieden Links für ein Gerät angezeigt werden sind die Angaben von Juis inkonsistent'
echo -e ' - Diese Liste ist weder vollständig, korrekt noch aktuell'
echo -e '\n### Release' ; cat xxx  | while read -s x; do echo " - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Labor'   ; cat lab  | while read -s x; do echo " - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Inhaus'  ; cat inh  | while read -s x; do echo " - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Dect'    ; cat dect | while read -s x; do echo " - MHW ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### BPjM'    ; cat bpjm | while read -s x; do echo " - CRC ${x%=*}: [${x##*/}](${x#*=})"; done
) | sed 's/_-/-/' > $PARENT/docs/JUIS.md

#tmp
rm -f xxx rel dwn lab inh dect bpjm bpjm.out

