#!/var/tmp/sh
############################################################
## Reverse lookup with dasoertliche.de
##
## ./isdn_mod_revers2.sh <number>
############################################################

number="$1"

url="http://www2.dasoertliche.de/?form_name=search_inv&page=RUECKSUCHE&context=RUECKSUCHE&action=STANDARDSUCHE&la=de&rci=no&ph=$number"
TEMP=$(wget -q -O - "$url" | grep -A 10 class=\"entry)
nameDO=$(echo "$TEMP" | sed -n -e 's/<[^<]*>/\ /g; s/^[^a-zA-Z0-9]*//g; 1p')
addrDO=$(echo "$TEMP" | sed -n -e 's/&nbsp;/ /g; s/<[^<]*>/ /g; s/^ *//g; $p')

if [ "$nameDO" != "" ] || [ "$addrDO" != "" ];
then
  echo $nameDO
  echo $addrDO
fi