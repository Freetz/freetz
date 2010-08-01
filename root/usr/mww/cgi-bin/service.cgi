#!/bin/sh

REG=/mod/etc/reg/daemon.reg
PATH=/bin:/usr/bin:/sbin:/usr/sbin

. /usr/lib/libmodcgi.sh

case $REQUEST_METHOD in
	POST)   source service_save.sh ;;
	GET|*)  source service_edit.sh ;;
esac
