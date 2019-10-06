
sec_begin 'Udevmount'

cgi_print_checkbox_p "stor_killblocker" "$MOD_STOR_KILLBLOCKER" \
	"$(lang de:"Alle Programme beenden die das Aush&auml;ngen verhindern." en:"Kill all programs blocking unmount.")"

cgi_print_checkbox_p "stor_autorunend" "$MOD_STOR_AUTORUNEND" \
	"$(lang de:"Automatisch autorun.sh und autoend.sh ausf&uuml;hren." en:"Run autorun.sh and autoend.sh automatically.")"

sec_end
