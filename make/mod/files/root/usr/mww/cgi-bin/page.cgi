#!/bin/sh
# Generically handle pages that are called like /cgi-bin/type/package/id


source /usr/lib/libmodcgi.sh

TYPE=${0##*/}
HANDLER_DIR="/usr/lib/mww/page.d/$TYPE"

if [ -z "$PATH_INFO" -o "$PATH_INFO" = "/" ]; then
	list="${HANDLER_DIR}/list.sh"
	if [ -r "$list" ]; then
		source "$list"
		exit
	fi
fi

path_info PACKAGE ID remaining_path
if ! valid package "$PACKAGE" || ! valid id "$ID"; then
	cgi_error "Invalid path"
	exit 1
fi

export PATH_INFO=$remaining_path
export SCRIPT_NAME="$SCRIPT_NAME/$PACKAGE${ID+/$ID}"
unset -v remaining_path

source "${HANDLER_DIR}/handler.sh"
