cgi --id=daemons
case $REQUEST_METHOD in
	POST)   source "${HANDLER_DIR}/save.sh" ;;
	GET|*)  source "${HANDLER_DIR}/list.sh" ;;
esac
