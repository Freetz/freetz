#!/var/tmp/sh

if [ ! -z "$(pidof 'dtmfbox')" ]; 
then
  status_daemon="running" 
else
  status_daemon="stopped"
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

cat << EOF
<html><head><title></title></head>
<body>

<pre style="font-size:11px">
<i><b>Accounts</b></i>
$status_accounts

<i><b>Verbindungen</b></i>
$status_connections

<i><b>Clients</b></i>
$status_clients
</pre>

$STATUS_REFRESH

</body>
</html>
EOF

