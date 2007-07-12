#!/bin/sh

# "FULLSCREEN" or "MOD" - change '/etc/init.d/rc.dtmfbox' also!
DESIGN="MOD"

PATH=/bin:/usr/bin:/sbin:/usr/sbin
SHOW=`echo ${QUERY_STRING} | sed -n 's/.*show=\(.*\)/\1/p' | sed -e 's/&.*//g'`
START=`echo ${QUERY_STRING} | sed -n 's/.*start=\(.*\)/\1/p' | sed -e 's/&.*//g'`
COMMAND=`echo ${QUERY_STRING} | sed -n 's/.*command=\(.*\)/\1/p' | sed -e 's/&.*//g'`
CLOSE=`echo ${QUERY_STRING} | sed -n 's/.*close=\(.*\)/\1/p' | sed -e 's/&.*//g'`

HREF="/cgi-bin/dtmfbox.cgi"

if [ "$DESIGN" = "MOD" ] && [ "$SHOW" = "" ]; 
then
  SHOW="status"
fi

if [ "$SHOW" = "" ];
then
  HREF="/cgi-bin/dtmfbox.cgi"

  echo "<script>location.href=\"$HREF\"</script>"
  echo "<a href=\"$HREF\">weiter...</a>"
fi

if [ "$SHOW" != "" ];
then

  export DESIGN="mod"
  export SHOW="$SHOW"  
  export START="$START"
  export CLOSE="$CLOSE"
  export COMMAND="$COMMAND"

  if [ "$START" = "" ]; then
	export CURRENT_PAGE="$SHOW"
  fi

  . /usr/mww/cgi-bin/dtmfbox.cgi
  
fi
