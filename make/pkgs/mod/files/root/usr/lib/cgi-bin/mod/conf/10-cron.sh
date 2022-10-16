sec_begin 'Cron'

cgi_print_radiogroup_service_starttype \
	"crond" "$MOD_CROND" "$(lang de:"Starttyp von crond" en:"crond start type")" "" 0

sec_end
