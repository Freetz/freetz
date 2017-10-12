#!/bin/sh


. /usr/lib/libmodcgi.sh

case $REQUEST_METHOD in
	POST)   source /usr/mww/cgi-bin/passwd_save.sh ;;
	GET|*)  source /usr/mww/cgi-bin/passwd_edit.sh ;;
esac
