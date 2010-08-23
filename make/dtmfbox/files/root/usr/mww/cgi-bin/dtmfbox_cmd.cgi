#!/var/tmp/sh
. ./dtmfbox_cfg.cgi

script=$(echo $QUERY_STRING | grep 'script=' | sed -e 's/.*script\=//' -e 's/\&.*//g')
script=$(echo ${script} | sed -r "s/%0D//g" | sed -r "s/%0A/\n/g")
script=$($HTTPD -d "$script")

binary=$(echo $QUERY_STRING | grep 'binary=' | sed -e 's/.*binary\=//' -e 's/\&.*//g')
binary=$(echo ${binary} | sed -r "s/%0D//g" | sed -r "s/%0A/\n/g")
binary=$($HTTPD -d "$binary")

file=$(echo $QUERY_STRING | grep 'download_name=' | sed -e 's/.*download_name\=//' -e 's/\&.*//g')
file=$(echo ${file} | sed -r "s/%0D//g" | sed -r "s/%0A/\n/g")
file=$($HTTPD -d "$file")

pid1=`echo ${QUERY_STRING} | sed -n 's/.*pid=\(.*\)/\1/p' | sed -e 's/&.*//g'`

# read security PID!
if [ -f /var/dtmfbox/tmp/webinterface.pid ];
then
	# check if pid equals with last pid saved
	pid2=`cat /var/dtmfbox/tmp/webinterface.pid`

	if [ "$pid1" = "$pid2" ]; 
	then

		if [ "$binary" = "true" ]; then
			echo "Content-Type: application/octet-stream\n\n"
			echo "Content-Disposition: attachment; filename=\"$file\";"
			echo ""
			exec $script
		else
			echo "Content-Type: text/html"
			echo ""
			echo ""
			echo -n "<font size='2' style='font-family:Arial'><b>$script</b></font><hr color='black'>"
			echo -n "<pre style='font-family: Courier; font-size:10px' id='cmd_output'>"
			echo -n "$script" | sed "s/$(echo -ne '\r')//g" | sh | sed -e 's/&/\&amp;/g ; s/</\&lt;/g ; s/>/\&gt;/g'
			echo -n "</pre>"
		fi
	fi
fi


# Security check failed!
if [ "$pid1" != "$pid2" ] || [ "$pid1" = "" ] || [ "$pid2" = "" ];
then
	echo "Content-Type: text/html"
	echo ""
	echo ""
	echo "<font color='red'>Error: Wrong PID! Security check failed!</font>"
fi
