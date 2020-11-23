#!/bin/sh

. /usr/lib/libmodcgi.sh


echo "<h1>Peers</h1>"

echo '<pre class="log full">'
wg show all | grep -v '(hidden)' | html
echo '</pre>'

