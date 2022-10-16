#!/bin/sh


. /usr/lib/libmodcgi.sh

path_info command _
case $command in
	*.*) cgi_error "Invalid command"; exit ;;
esac

script="exec.d/$command.sh"
if [ -r "$script" ]; then
	source "$script"
else
	cgi_error "$(lang de:"Unbekannter Befehl" en:"unknown command") '$command'"
fi
