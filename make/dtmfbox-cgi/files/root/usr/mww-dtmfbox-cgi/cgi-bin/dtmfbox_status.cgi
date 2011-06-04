#!/bin/sh
. ./dtmfbox_cfg.cgi

if [ ! -z "$(pidof 'dtmfbox')" ]; 
then
  status_daemon="running" 
else
  status_daemon="stopped"
fi

# &pid=
if [ "${QUERY_STRING}" != "" ] && [ "$PID" = "" ]; then
	PID=`echo ${QUERY_STRING} | sed -n 's/.*pid=\(.*\)/\1/p' | sed -e 's/&.*//g'`
fi 

# &no_startstop=
if [ "${QUERY_STRING}" != "" ] && [ "$NO_STARTSTOP" = "" ]; then
	NO_STARTSTOP=`echo ${QUERY_STRING} | sed -n 's/.*no_startstop=\(.*\)/\1/p' | sed -e 's/&.*//g'`
fi 


DO_REFRESH="10000"
if [ "$DO_REFRESH" != "" ];
then
  STATUS_REFRESH="<script>window.setTimeout(\"location.reload(false)\", $DO_REFRESH);</script>";
fi

if [ "$status_daemon" = "running" ];
then	  
	status_accounts="`dtmfbox -list accounts`"
	status_connections="`dtmfbox -list`"
	status_clients="`dtmfbox -list clients`"
fi


# view log?
if [ -f "/var/dtmfbox/tmp/dtmfbox.log" ] && [ "$NO_STARTSTOP" != "1" ]; then
	VIEWLOG_CMD="dtmfbox_cmd.cgi?binary=false&pid=$PID&script=cat%20/var/dtmfbox/tmp/dtmfbox.log"
	DELETELOG_CMD="$MAIN_CGI&pid=$PID&run_cmd=rm%20/var/dtmfbox/tmp/dtmfbox.log"
	btnViewLog="<td><input type='button' value='Log ansehen' onclick=\"javascript:window.open('$VIEWLOG_CMD');\" id='view_log' name='view_log'>"
	if [ "$status_daemon" != "running" ];
	then
		btnViewLog="$btnViewLog <input type='button' value='Log löschen' onclick=\"javascript:parent.location.href='$DELETELOG_CMD'\">"
	fi
	btnViewLog="$btnViewLog</td>"
fi


cat << EOF
Content-Type: text/html


<html><head><title>dtmfbox - Status</title></head>
<style type="text/css">
EOF
cat "$STYLE_CSS"
cat << EOF
</style>
<body style='margin:7px'>
  <table border="0" cellpadding="3" cellspacing="0"><tr>
EOF
if [ "$NO_STARTSTOP" != "1" ]; then
if [ "$status_daemon" = "running" ];
then
cat << EOF
	<td width="150"><font size="2" color="green"><i><b>dtmfbox running!</b></i></font></td>
	<td align="center"><input type="button" value="Restart" onclick="javascript:parent.location.href='$MAIN_CGI&start=daemon&show=$CURRENT_PAGE'" id="start_daemon" name="start_daemon"></td>
	<td align="center"><input type="button" value="Restart (Log)" onclick="javascript:parent.location.href='$MAIN_CGI&start=logged&show=$CURRENT_PAGE'" id="start_logged" name="start_logged"></td>
	<td align="center"><input type="button" value="Stoppen" onclick="javascript:parent.location.href='$MAIN_CGI&start=stop&show=$CURRENT_PAGE'" id="stop_daemon" name="stop_daemon"></td>	
EOF
else
cat << EOF
	<td width="150"><font size="2" color="red"><i><b>dtmfbox stopped!</b></i></font></td>
	<td align="center"><input type="button" value="Starten" onclick="javascript:parent.location.href='$MAIN_CGI&start=daemon&show=$CURRENT_PAGE'" id="start_daemon" name="start_daemon"></td>
	<td align="center"><input type="button" value="Starten (Log)" onclick="javascript:parent.location.href='$MAIN_CGI&start=logged&show=$CURRENT_PAGE'" id="start_logged" name="start_logged"></td>
EOF
fi
fi

cat << EOF
  $btnViewLog
  </tr>
  </table>
 
<pre style="font-size:11px;border:0px" width="85%" class='code'>
EOF

if [ "$status_daemon" = "running" ];
then
cat << EOF
<i><b>Accounts</b></i>
$status_accounts

<i><b>Verbindungen</b></i>
$status_connections

<i><b>Clients</b></i>
$status_clients
</pre>
EOF
fi

cat << EOF
$STATUS_REFRESH
</body>
</html>
EOF

